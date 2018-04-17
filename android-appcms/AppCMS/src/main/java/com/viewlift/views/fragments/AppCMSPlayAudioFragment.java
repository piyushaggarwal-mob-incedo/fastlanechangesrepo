package com.viewlift.views.fragments;


import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.ActivityInfo;
import android.content.res.Configuration;
import android.database.ContentObserver;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.PorterDuff;
import android.graphics.Typeface;
import android.graphics.drawable.Drawable;
import android.media.AudioManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.RemoteException;
import android.os.SystemClock;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.support.v4.content.ContextCompat;
import android.support.v4.media.MediaBrowserCompat;
import android.support.v4.media.MediaDescriptionCompat;
import android.support.v4.media.MediaMetadataCompat;
import android.support.v4.media.session.MediaControllerCompat;
import android.support.v4.media.session.MediaSessionCompat;
import android.support.v4.media.session.PlaybackStateCompat;
import android.support.v7.app.AlertDialog;
import android.text.TextUtils;
import android.text.format.DateUtils;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.SeekBar;
import android.widget.TextView;
import android.widget.Toast;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.engine.Resource;
import com.bumptech.glide.request.RequestOptions;
import com.google.android.gms.cast.Cast;
import com.google.android.gms.cast.framework.CastContext;
import com.google.android.gms.cast.framework.CastSession;
import com.viewlift.AppCMSApplication;
import com.viewlift.Audio.AudioServiceHelper;
import com.viewlift.Audio.MusicService;
import com.viewlift.Audio.playback.AudioPlaylistHelper;
import com.viewlift.Audio.ui.PlaybackControlsFragment;
import com.viewlift.R;
import com.viewlift.casting.CastHelper;
import com.viewlift.presenters.AppCMSPresenter;
import com.viewlift.views.customviews.BaseView;
import com.viewlift.views.customviews.ViewCreator;

import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;

import butterknife.BindView;
import butterknife.ButterKnife;
import jp.wasabeef.glide.transformations.BlurTransformation;
import rx.functions.Action0;

import static android.view.View.GONE;
import static android.view.View.INVISIBLE;
import static android.view.View.VISIBLE;


/**
 * A simple {@link Fragment} subclass.
 */
public class AppCMSPlayAudioFragment extends Fragment implements View.OnClickListener {
    private static final long PROGRESS_UPDATE_INTERNAL = 1000;
    private static final long PROGRESS_UPDATE_INITIAL_INTERVAL = 100;
    private final Handler mHandler = new Handler();
    private final ScheduledExecutorService mExecutorService =
            Executors.newSingleThreadScheduledExecutor();
    @BindView(R.id.track_image)
    ImageView trackImage;

    @BindView(R.id.track_image_blurred)
    ImageView track_image_blurred;

    @BindView(R.id.track_name)
    TextView trackName;
    @BindView(R.id.artist_name)

    TextView artistName;
    @BindView(R.id.track_year)
    TextView trackYear;
    @BindView(R.id.album_name)
    TextView albumName;
    @BindView(R.id.start_time)
    TextView trackStartTime;
    @BindView(R.id.end_time)
    TextView trackEndTime;
    @BindView(R.id.seek_audio)
    SeekBar seekAudio;
    @BindView(R.id.seek_volume)
    SeekBar seekVolume;
    @BindView(R.id.shuffle)
    ImageButton shuffle;
    @BindView(R.id.prev)
    ImageButton previousTrack;
    @BindView(R.id.play_pause)
    ImageButton playPauseTrack;
    @BindView(R.id.next)
    ImageButton nextTrack;
    @BindView(R.id.playlist)
    ImageButton playlist;
    @BindView(R.id.extra_info)
    TextView extra_info;
    @BindView(R.id.progressBarLoading)
    ProgressBar progressBarLoading;
    @BindView(R.id.progressBarPlayPause)
    ProgressBar progressBarPlayPause;
    int currentProgess;
    VolumeObserver volumeObserver;
    boolean isVisible = true;
    long duration = 0;
    private MediaBrowserCompat mMediaBrowser;
    private Drawable mPauseDrawable;
    private Drawable mPlayDrawable;
    private String mCurrentArtUrl;
    private OnUpdateMetaChange onUpdateMetaChange;
    private ScheduledFuture<?> mScheduleFuture;
    private PlaybackStateCompat mLastPlaybackState;
    boolean isDialogVisible = false;
    int connectionTry = 0;

    private final Runnable mUpdateProgressTask = new Runnable() {
        @Override
        public void run() {
            updateProgress();
        }
    };
    private AppCMSPresenter appCMSPresenter;
    private final MediaControllerCompat.Callback mCallback = new MediaControllerCompat.Callback() {
        @Override
        public void onPlaybackStateChanged(@NonNull PlaybackStateCompat state) {
            System.out.println("update playback state in fullscreen" + state);
            updatePlaybackState(state);
        }

        @Override
        public void onMetadataChanged(MediaMetadataCompat metadata) {
            if (metadata != null) {
                currentProgess = 0;
                updateMediaDescription(metadata);
                updateDuration(metadata);
                onUpdateMetaChange.updateMetaData(metadata);
//                checkSubscription(metadata);
            }
        }
    };
    private final MediaBrowserCompat.ConnectionCallback mConnectionCallback =
            new MediaBrowserCompat.ConnectionCallback() {
                @Override
                public void onConnected() {
                    try {
                        connectToSession(mMediaBrowser.getSessionToken());
                    } catch (RemoteException e) {
                        e.printStackTrace();
                    }
                }
            };


    public static AppCMSPlayAudioFragment newInstance(Context context) {
        AppCMSPlayAudioFragment appCMSPlayAudioFragment = new AppCMSPlayAudioFragment();
        Bundle args = new Bundle();

        appCMSPlayAudioFragment.setArguments(args);


        return appCMSPlayAudioFragment;
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);

        if (context instanceof OnUpdateMetaChange) {
            onUpdateMetaChange = (OnUpdateMetaChange) context;
        }

    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mMediaBrowser = new MediaBrowserCompat(getActivity(),
                new ComponentName(getActivity(), MusicService.class), mConnectionCallback, null);
        recevierPreview = new PreviewReceiver();
        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction(AudioServiceHelper.APP_CMS_SHOW_PREVIEW_ACTION);
        getActivity().registerReceiver(recevierPreview, intentFilter);
    }


    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View rootView = inflater.inflate(R.layout.fragment_app_cmsplay_audio, container, false);
        ButterKnife.bind(this, rootView);
        shuffle.setOnClickListener(this);
        previousTrack.setOnClickListener(this);
        playPauseTrack.setOnClickListener(this);
        nextTrack.setOnClickListener(this);
        playlist.setOnClickListener(this);
        mPauseDrawable = ContextCompat.getDrawable(getActivity(), R.drawable.pause_track);
        mPlayDrawable = ContextCompat.getDrawable(getActivity(), R.drawable.play_track);
        isDialogVisible = false;
        appCMSPresenter = ((AppCMSApplication) getActivity().getApplication()).
                getAppCMSPresenterComponent().appCMSPresenter();
        if (!BaseView.isTablet(getActivity())) {
            getActivity().setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
        }
        seekAudio.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                currentProgess = (progress / 1000);
                trackStartTime.setText(DateUtils.formatElapsedTime(progress / 1000));
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
                stopSeekbarUpdate();
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                MediaControllerCompat.getMediaController(getActivity()).getTransportControls().seekTo(seekBar.getProgress());
                scheduleSeekbarUpdate();
            }
        });
        updateFromParams(getActivity().getIntent());

        setProgress();
        updataeShuffleState();

        setPlaylistVisibility();

        final AudioManager audioManager = (AudioManager) getActivity().getSystemService(Context.AUDIO_SERVICE);
        int maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC);
        int initVolume = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC);
        seekVolume.setMax(maxVolume);
        seekVolume.setProgress(initVolume);
        seekVolume.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int i, boolean b) {
                CastSession castSession = CastContext.getSharedInstance(getContext()).getSessionManager()
                        .getCurrentCastSession();
                audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, i, AudioManager.ADJUST_SAME);

//                if (castSession != null && castSession.isConnected()) {
////                    audioManager.setStreamVolume(AudioManager.USE_DEFAULT_STREAM_TYPE, i, AudioManager.ADJUST_SAME);
//
//                    audioManager.adjustSuggestedStreamVolume(AudioManager.ADJUST_RAISE,
//                            AudioManager.USE_DEFAULT_STREAM_TYPE, AudioManager.FLAG_SHOW_UI);
////                    audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, i, AudioManager.ADJUST_SAME);
//
//                } else {
//                    audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, i, AudioManager.ADJUST_SAME);
//
//                }

            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {

            }
        });

        volumeObserver = new VolumeObserver(getActivity(), new Handler());

        setTypeFace(getContext(), trackName, getContext().getString(R.string.opensans_bold_ttf));
        setTypeFace(getContext(), artistName, getContext().getString(R.string.opensans_bold_ttf));
        setTypeFace(getContext(), trackYear, getContext().getString(R.string.opensans_semibold_ttf));
        setTypeFace(getContext(), albumName, getContext().getString(R.string.opensans_bold_ttf));

        return rootView;
    }

    @Override
    public void onResume() {
        super.onResume();
        isVisible = true;
        audioPreview(false);
        appCMSPresenter.setCancelAllLoads(false);

        getActivity().getContentResolver().registerContentObserver(android.provider.Settings.System.CONTENT_URI, true, volumeObserver);
    }

    private void setProgress() {
        if (progressBarLoading != null) {
            try {
                progressBarLoading.getIndeterminateDrawable().setTint(Color.parseColor(appCMSPresenter.getAppCMSMain()
                        .getBrand().getCta().getPrimary().getBackgroundColor()));
            } catch (Exception e) {
                progressBarLoading.getIndeterminateDrawable().setTint(ContextCompat.getColor(getActivity(), R.color.colorAccent));
            }
        }
    }

    private void updataeShuffleState() {
        if (appCMSPresenter.getAudioShuffledPreference()) {
            int tintColor = Color.parseColor(ViewCreator.getColor(getActivity(),
                    appCMSPresenter.getAppCMSMain().getBrand().getCta().getPrimary().getBackgroundColor()));
            applyTintToDrawable(shuffle.getBackground(), tintColor);
        } else {

            int tintColor = (getActivity().getResources().getColor(android.R.color.darker_gray));
            applyTintToDrawable(shuffle.getBackground(), tintColor);
        }
    }

    private void applyTintToDrawable(@Nullable Drawable drawable, int color) {
        if (drawable != null) {
            drawable.setTint(color);
            drawable.setTintMode(PorterDuff.Mode.MULTIPLY);
        }
    }

    @Override
    public void onClick(View view) {
        if (view == shuffle) {
            if (appCMSPresenter.getAudioShuffledPreference()) {
                appCMSPresenter.setAudioShuffledPreference(false);
                AudioPlaylistHelper.getInstance().undoShufflePlaylist();
            } else {
                appCMSPresenter.setAudioShuffledPreference(true);
                AudioPlaylistHelper.getInstance().doShufflePlaylist();
            }
            updataeShuffleState();
        }

        if (view == previousTrack) {
            MediaControllerCompat.TransportControls controls = MediaControllerCompat.getMediaController(getActivity()).getTransportControls();
            controls.skipToPrevious();
        }
        if (view == playPauseTrack) {
            PlaybackStateCompat state = MediaControllerCompat.getMediaController(getActivity()).getPlaybackState();
            if (state != null) {
                MediaControllerCompat.TransportControls controls = MediaControllerCompat.getMediaController(getActivity()).getTransportControls();
                switch (state.getState()) {
                    case PlaybackStateCompat.STATE_PLAYING: // fall through
                    case PlaybackStateCompat.STATE_BUFFERING:
                        controls.pause();
                        stopSeekbarUpdate();
                        break;
                    case PlaybackStateCompat.STATE_PAUSED:
                    case PlaybackStateCompat.STATE_STOPPED:
                        controls.play();
                        scheduleSeekbarUpdate();
                        audioPreview(true);
                        break;
                    default:
                }
            }
        }
        if (view == nextTrack) {
            MediaControllerCompat.TransportControls controls = MediaControllerCompat.getMediaController(getActivity()).getTransportControls();
            controls.skipToNext();
        }

        if (view == playlist) {
            if (AudioPlaylistHelper.getInstance().getCurrentPlaylistData() != null) {
                appCMSPresenter.navigatePlayListPageWithPreLoadData(AudioPlaylistHelper.getInstance().getCurrentPlaylistData());
                getActivity().finish();
            } else {
                Toast.makeText(getActivity(), getString(R.string.not_item_available_inqueue), Toast.LENGTH_SHORT).show();
            }
        }
    }


    void audioPreview(boolean isPlay) {
        if (getActivity() != null
                && MediaControllerCompat.getMediaController(getActivity()) != null
                && MediaControllerCompat.getMediaController(getActivity()).getTransportControls() != null) {
            MediaControllerCompat.TransportControls controls = MediaControllerCompat.getMediaController(getActivity()).getTransportControls();
            MediaMetadataCompat metadata = MediaControllerCompat.getMediaController(getActivity()).getMetadata();
            String isFree = (String) metadata.getText(AudioPlaylistHelper.CUSTOM_METADATA_IS_FREE);
            if (((appCMSPresenter.isUserSubscribed()) && appCMSPresenter.isUserLoggedIn()) || Boolean.valueOf(isFree)) {
                if (isPlay) {
                    controls.play();
                }
                scheduleSeekbarUpdate();
            } else {
                if (appCMSPresenter != null && appCMSPresenter.getAppCMSMain() != null
                        && appCMSPresenter.getAppCMSMain().getFeatures() != null
                        && appCMSPresenter.getAppCMSMain().getFeatures().getAudioPreview() != null) {
                    if (appCMSPresenter.getAppCMSMain().getFeatures().getAudioPreview().isAudioPreview()) {
                        if ((currentProgess) >= Integer.parseInt(appCMSPresenter.getAppCMSMain().getFeatures().getAudioPreview().getLength().getMultiplier())) {
                            stopSeekbarUpdate();
                            showEntitleMentDialog();
                        }
                    }
                } else {
                    showEntitleMentDialog();
                }
            }
        }
    }

    private void setPlaylistVisibility() {
        if (AudioPlaylistHelper.getInstance().getCurrentPlaylistData() == null) {
            playlist.setVisibility(View.INVISIBLE);
        }
    }

    private void connectToSession(MediaSessionCompat.Token token) throws RemoteException {
        MediaControllerCompat mediaController = new MediaControllerCompat(
                getActivity(), token);
        if (mediaController.getMetadata() == null) {
            if (connectionTry == 0 && mMediaBrowser != null) {
                mMediaBrowser.connect();
            } else {
                getActivity().finish();
            }
            connectionTry++;
            return;
        }
        MediaControllerCompat.setMediaController(getActivity(), mediaController);
        mediaController.registerCallback(mCallback);
        PlaybackStateCompat state = mediaController.getPlaybackState();

        updatePlaybackState(state);
        MediaMetadataCompat metadata = mediaController.getMetadata();
        if (metadata != null) {
            updateMediaDescription(metadata);
            updateDuration(metadata);
        }
        updateProgress();
        if (state != null && (state.getState() == PlaybackStateCompat.STATE_PLAYING ||
                state.getState() == PlaybackStateCompat.STATE_BUFFERING)) {
            scheduleSeekbarUpdate();
        }
        checkSubscription(metadata);
    }

    private void updateFromParams(Intent intent) {
        if (intent != null) {
            MediaMetadataCompat description = intent.getParcelableExtra(
                    PlaybackControlsFragment.EXTRA_CURRENT_MEDIA_DESCRIPTION);
            if (description != null) {
                updateMediaDescription(description);
            }
        }
    }

    private void scheduleSeekbarUpdate() {
        stopSeekbarUpdate();
        if (!mExecutorService.isShutdown()) {
            mScheduleFuture = mExecutorService.scheduleAtFixedRate(
                    new Runnable() {
                        @Override
                        public void run() {
                            mHandler.post(mUpdateProgressTask);
                        }
                    }, PROGRESS_UPDATE_INITIAL_INTERVAL,
                    PROGRESS_UPDATE_INTERNAL, TimeUnit.MILLISECONDS);
        }
    }

    private void stopSeekbarUpdate() {
        if (mScheduleFuture != null) {
            mScheduleFuture.cancel(false);
        }
    }

    @Override
    public void onStart() {
        super.onStart();
        if (mMediaBrowser != null) {
            mMediaBrowser.connect();
        }
    }

    @Override
    public void onStop() {
        super.onStop();
        if (mMediaBrowser != null) {
            mMediaBrowser.disconnect();
        }
        MediaControllerCompat controllerCompat = MediaControllerCompat.getMediaController(getActivity());
        if (controllerCompat != null) {
            controllerCompat.unregisterCallback(mCallback);
        }
        isVisible = false;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        stopSeekbarUpdate();
        mExecutorService.shutdown();
        getActivity().unregisterReceiver(recevierPreview);
        getActivity().getContentResolver().unregisterContentObserver(volumeObserver);
        appCMSPresenter.setCurrentPlayingVideo(null);

    }

    private void fetchImageAsync(@NonNull MediaDescriptionCompat description) {
        if (description.getIconUri() == null) {
            track_image_blurred.setImageResource(R.drawable.placeholder_audio);
            mCurrentArtUrl = "";
        } else {
            mCurrentArtUrl = description.getIconUri().toString();

        }


        if (getActivity() != null) {
            RequestOptions requestOptions = new RequestOptions().centerInside().error(R.drawable.placeholder_audio)
                    .transform(new ImageBlurTransformation(getContext(), mCurrentArtUrl));
            Glide.with(getActivity())
                    .load(mCurrentArtUrl).apply(new RequestOptions().centerInside()
                    .fitCenter())
                    .into(trackImage);
            Glide.with(getActivity())
                    .load(mCurrentArtUrl).apply(requestOptions)
                    .into(track_image_blurred);
        }

    }

    private void updateMediaDescription(MediaMetadataCompat metaData) {
        if (metaData == null) {
            return;
        }
        String directorName = "";
        trackName.setText(metaData.getDescription().getTitle());
        if (metaData.getText(AudioPlaylistHelper.CUSTOM_METADATA_TRACK_DIRECTOR) != null && !TextUtils.isEmpty(metaData.getText(AudioPlaylistHelper.CUSTOM_METADATA_TRACK_DIRECTOR))) {
            directorName = (String) metaData.getText(AudioPlaylistHelper.CUSTOM_METADATA_TRACK_DIRECTOR);
            directorName = " (" + directorName + ")";
        }
        appCMSPresenter.setCurrentPlayingVideo(metaData.getDescription().getMediaId());

        artistName.setText(metaData.getText(MediaMetadataCompat.METADATA_KEY_ARTIST) + "" + directorName);
        String trackYearValue = metaData.getText(AudioPlaylistHelper.CUSTOM_METADATA_TRACK_ALBUM_YEAR) + "";
        if (TextUtils.isEmpty(trackYearValue)) {
            trackYear.setVisibility(View.GONE);
        } else {
            trackYear.setVisibility(View.VISIBLE);
            trackYear.setText(trackYearValue);
            trackYear.setLetterSpacing(0.3f);
            trackYear.setAllCaps(true);
        }
        fetchImageAsync(metaData.getDescription());
    }

    public void checkSubscription(MediaMetadataCompat metadata) {
        if (getActivity() != null) {
            audioPreview(false);
        }
    }

    private void showEntitleMentDialog() {
        MediaControllerCompat.TransportControls controls = MediaControllerCompat.getMediaController(getActivity()).getTransportControls();
        if (!((appCMSPresenter.isUserSubscribed()) && appCMSPresenter.isUserLoggedIn())) {
            controls.pause();
            stopSeekbarUpdate();
            if (!isDialogVisible && isVisible && getActivity() != null) {
                isDialogVisible = true;
                appCMSPresenter.setAudioPlayerOpen(true);
                if (appCMSPresenter.isUserLoggedIn()) {
                    if (appCMSPresenter.dialog != null && appCMSPresenter.dialog.isShowing()) {
                        appCMSPresenter.dialog.dismiss();
                        appCMSPresenter.isDialogShown = false;
                    }
                    appCMSPresenter.showEntitlementDialog(AppCMSPresenter.DialogType.SUBSCRIPTION_REQUIRED_AUDIO_PREVIEW,
                            new Action0() {
                                @Override
                                public void call() {
                                    isDialogVisible = false;
                                    if (getActivity() != null) {
                                        getActivity().finish();
                                        appCMSPresenter.stopAudioServices();
                                        stopSeekbarUpdate();
                                    }
                                }
                            });
                } else {
                    if (appCMSPresenter.dialog != null && appCMSPresenter.dialog.isShowing()) {
                        try {
                            appCMSPresenter.dialog.dismiss();
                        } catch (IllegalArgumentException e) {
                            e.printStackTrace();
                        }
                        appCMSPresenter.isDialogShown = false;

                    }
                    appCMSPresenter.showEntitlementDialog(AppCMSPresenter.DialogType.LOGIN_AND_SUBSCRIPTION_REQUIRED_AUDIO_PREVIEW,
                            new Action0() {
                                @Override
                                public void call() {
                                    isDialogVisible = false;
                                    if (getActivity() != null) {
                                        getActivity().finish();
                                        appCMSPresenter.stopAudioServices();
                                        stopSeekbarUpdate();

                                    }
                                }
                            });
                }
            }
        }
    }

    private void updateDuration(MediaMetadataCompat metadata) {
        if (metadata == null) {
            return;
        }
        if (duration != metadata.getLong(MediaMetadataCompat.METADATA_KEY_DURATION)) {
            if (metadata.getLong(MediaMetadataCompat.METADATA_KEY_DURATION) > 0) {
                duration = metadata.getLong(MediaMetadataCompat.METADATA_KEY_DURATION);
                seekAudio.setMax((int) duration);
                seekAudio.setProgress(0);
                trackEndTime.setText(DateUtils.formatElapsedTime(duration / 1000));
            }
        }
    }

    private void updatePlaybackState(PlaybackStateCompat state) {
        if (state == null) {
            return;
        }
        mLastPlaybackState = state;
        if (CastHelper.getInstance(getActivity().getApplicationContext()).getDeviceName() != null && !TextUtils.isEmpty(CastHelper.getInstance(getActivity().getApplicationContext()).getDeviceName())) {
            String castName = CastHelper.getInstance(getActivity().getApplicationContext()).getDeviceName();
            String line3Text = castName == null ? "" : getResources()
                    .getString(R.string.casting_to_device, castName);
            extra_info.setText(line3Text);
            extra_info.setVisibility(View.VISIBLE);
        } else {
            extra_info.setVisibility(View.GONE);
        }
        MediaControllerCompat controller = MediaControllerCompat.getMediaController(getActivity());
        MediaMetadataCompat metadata = controller.getMetadata();
//        checkSubscription(metadata);
        switch (state.getState()) {
            case PlaybackStateCompat.STATE_PLAYING:
                playPauseTrack.setVisibility(VISIBLE);
                playPauseTrack.setBackground(mPauseDrawable);
                progressBarPlayPause.setVisibility(GONE);
                scheduleSeekbarUpdate();

                break;
            case PlaybackStateCompat.STATE_PAUSED:
                playPauseTrack.setVisibility(VISIBLE);
                playPauseTrack.setBackground(mPlayDrawable);
                progressBarPlayPause.setVisibility(GONE);
                updateProgress();
                stopSeekbarUpdate();
                break;
            case PlaybackStateCompat.STATE_NONE:
            case PlaybackStateCompat.STATE_STOPPED:
                playPauseTrack.setVisibility(VISIBLE);
                playPauseTrack.setBackground(mPlayDrawable);
                progressBarPlayPause.setVisibility(GONE);
                stopSeekbarUpdate();
                getActivity().finish();
                break;

            case PlaybackStateCompat.STATE_BUFFERING:
                playPauseTrack.setVisibility(INVISIBLE);
                progressBarPlayPause.setVisibility(View.VISIBLE);
                stopSeekbarUpdate();

                break;
            default:
        }

        nextTrack.setVisibility((state.getActions() & PlaybackStateCompat.ACTION_SKIP_TO_NEXT) == 0
                ? INVISIBLE : VISIBLE);
        previousTrack.setVisibility((state.getActions() & PlaybackStateCompat.ACTION_SKIP_TO_PREVIOUS) == 0
                ? INVISIBLE : VISIBLE);
    }

    private void updateProgress() {
        if (mLastPlaybackState == null) {
            return;
        }
        long currentPosition = mLastPlaybackState.getPosition();
        if (mLastPlaybackState.getState() == PlaybackStateCompat.STATE_PLAYING) {
            // Calculate the elapsed time between the last position update and now and unless
            // paused, we can assume (delta * speed) + current position is approximately the
            // latest position. This ensure that we do not repeatedly call the getPlaybackState()
            // on MediaControllerCompat.
            long timeDelta = SystemClock.elapsedRealtime() -
                    mLastPlaybackState.getLastPositionUpdateTime();
            currentPosition += (int) timeDelta * mLastPlaybackState.getPlaybackSpeed();
        }
        seekAudio.setProgress((int) currentPosition);
        currentProgess = (int) (currentPosition / 1000);
        audioPreview(false);

    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {

        super.onConfigurationChanged(newConfig);
    }

    public interface OnUpdateMetaChange {
        void updateMetaData(MediaMetadataCompat metadata);
    }

    public class VolumeObserver extends ContentObserver {
        private AudioManager audioManager;

        public VolumeObserver(Context context, Handler handler) {
            super(handler);
            audioManager = (AudioManager) context.getSystemService(Context.AUDIO_SERVICE);
        }

        @Override
        public boolean deliverSelfNotifications() {
            return false;
        }

        @Override
        public void onChange(boolean selfChange) {
            CastSession castSession = CastContext.getSharedInstance(getContext()).getSessionManager()
                    .getCurrentCastSession();
            if (castSession != null && castSession.isConnected()) {
                seekVolume.setProgress(audioManager.getStreamVolume(AudioManager.STREAM_MUSIC));

            } else {
                seekVolume.setProgress(audioManager.getStreamVolume(AudioManager.STREAM_MUSIC));

            }

        }
    }

    private PreviewReceiver recevierPreview;

    private class PreviewReceiver extends BroadcastReceiver {

        @Override
        public void onReceive(Context arg0, Intent arg1) {

            if (arg1 != null && arg1.hasExtra(AudioServiceHelper.APP_CMS_SHOW_PREVIEW_MESSAGE)) {
                audioPreview(false);
            }
        }
    }

    private void setTypeFace(Context context,
                             TextView view, String fontType) {
        if (null != context && null != view && null != fontType) {
            try {
                Typeface face = Typeface.createFromAsset(context.getAssets(), fontType);
                view.setTypeface(face);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    private static class ImageBlurTransformation extends BlurTransformation {
        private final String ID;

        public ImageBlurTransformation(Context context, String imageUrl) {
            super(context);
            this.ID = imageUrl;
        }

        @Override
        public boolean equals(Object obj) {
            return obj instanceof ImageBlurTransformation;
        }

        @Override
        public void updateDiskCacheKey(@NonNull MessageDigest messageDigest) {
            try {
                byte[] ID_BYTES = ID.getBytes(STRING_CHARSET_NAME);
                messageDigest.update(ID_BYTES);
            } catch (UnsupportedEncodingException e) {
            }
        }

        @Override
        public int hashCode() {
            return ID.hashCode();
        }

        @NonNull
        @Override
        public Resource<Bitmap> transform(@NonNull Context context, @NonNull Resource<Bitmap> resource, int outWidth, int outHeight) {
            return super.transform(resource, outWidth, outHeight);
        }
    }
}
