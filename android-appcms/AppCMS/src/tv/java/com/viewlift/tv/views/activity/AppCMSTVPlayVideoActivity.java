package com.viewlift.tv.views.activity;

import android.app.Activity;
import android.app.FragmentManager;
import android.app.FragmentTransaction;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Handler;
import android.support.annotation.Nullable;
import android.text.TextUtils;
import android.view.KeyEvent;
import android.view.WindowManager;
import android.widget.FrameLayout;

import com.viewlift.AppCMSApplication;
import com.viewlift.R;
import com.viewlift.models.data.appcms.api.AppCMSSignedURLResult;
import com.viewlift.models.data.appcms.api.ClosedCaptions;
import com.viewlift.models.data.appcms.api.Gist;
import com.viewlift.models.data.appcms.api.Mpeg;
import com.viewlift.models.data.appcms.api.VideoAssets;
import com.viewlift.presenters.AppCMSPresenter;
import com.viewlift.tv.utility.Utils;
import com.viewlift.tv.views.fragment.AppCMSPlayVideoFragment;
import com.viewlift.tv.views.fragment.AppCmsGenericDialogFragment;
import com.viewlift.tv.views.fragment.AppCmsLoginDialogFragment;
import com.viewlift.tv.views.fragment.AppCmsResetPasswordFragment;
import com.viewlift.tv.views.fragment.AppCmsSignUpDialogFragment;
import com.viewlift.tv.views.fragment.AppCmsTvErrorFragment;
import com.viewlift.tv.views.fragment.ClearDialogFragment;
import com.viewlift.views.binders.AppCMSBinder;
import com.viewlift.views.binders.AppCMSVideoPageBinder;
import com.viewlift.views.customviews.VideoPlayerView;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import rx.functions.Action1;


/**
 * Created by viewlift on 6/14/17.
 */

public class AppCMSTVPlayVideoActivity extends Activity implements
        AppCMSPlayVideoFragment.OnClosePlayerEvent, AppCmsTvErrorFragment.ErrorFragmentListener,
        VideoPlayerView.StreamingQualitySelector {
    private static final String TAG = "TVPlayVideoActivity";

    private BroadcastReceiver handoffReceiver;
    private AppCMSPresenter appCMSPresenter;
    FrameLayout appCMSPlayVideoPageContainer;

    private AppCMSVideoPageBinder binder;

    private AppCMSPlayVideoFragment appCMSPlayVideoFragment;
    private String title;
    private String hlsUrl;
    private String videoImageUrl;
    private String filmId;
    private String primaryCategory;
    private List<String> relateVideoIds;
    private int currentlyPlayingIndex = 0;
    private AppCmsResetPasswordFragment appCmsResetPasswordFragment;
    private Map<String, String> availableStreamingFormats;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_tv_video_player_page);
        appCMSPresenter =
                ((AppCMSApplication) getApplication()).getAppCMSPresenterComponent().appCMSPresenter();

        appCMSPlayVideoPageContainer =
                (FrameLayout) findViewById(R.id.app_cms_play_video_page_container);
        Intent intent = getIntent();
        Bundle bundleExtra = intent.getBundleExtra(getString(R.string.app_cms_video_player_bundle_binder_key));
        try {
            binder = (AppCMSVideoPageBinder)
                    bundleExtra.getBinder(getString(R.string.app_cms_video_player_binder_key));
            if (binder != null
                    && binder.getContentData() != null
                    && binder.getContentData().getGist() != null) {
                if (binder.isTrailer()) {
                    String id = null;
                    if (binder.getContentData() != null &&
                            binder.getContentData().getContentDetails() != null &&
                            binder.getContentData().getContentDetails().getTrailers() != null &&
                            !binder.getContentData().getContentDetails().getTrailers().isEmpty() &&
                            binder.getContentData().getContentDetails().getTrailers().get(0) != null) {
                        id = binder.getContentData().getContentDetails().getTrailers().get(0).getId();
                    } else if (binder.getContentData().getShowDetails() != null &&
                            binder.getContentData().getShowDetails().getTrailers() != null &&
                            !binder.getContentData().getShowDetails().getTrailers().isEmpty() &&
                            binder.getContentData().getShowDetails().getTrailers().get(0) != null &&
                            binder.getContentData().getShowDetails().getTrailers().get(0).getId() != null) {
                        id = binder.getContentData().getShowDetails().getTrailers().get(0).getId();
                    }
                    if (id != null) {
                        appCMSPresenter.refreshVideoData(id,
                                updatedContentDatum -> {
                                    if (!AppCMSTVPlayVideoActivity.this.isFinishing()) {
                                        try {
                                            binder.setContentData(updatedContentDatum);
                                        } catch (Exception e) {
                                            //
                                        }
                                        appCMSPresenter.getAppCMSSignedURL(binder.getContentData().getGist().getId(), appCMSSignedURLResult -> {
                                            launchVideoPlayer(updatedContentDatum.getGist() , appCMSSignedURLResult);
                                        });
                                    }
                                });
                    }
                } else {
                    appCMSPresenter.getAppCMSSignedURL(binder.getContentData().getGist().getId(), appCMSSignedURLResult -> {
                        launchVideoPlayer(binder.getContentData().getGist() , appCMSSignedURLResult);
                    });
                }
            }
        } catch (ClassCastException e) {
            e.printStackTrace();
        }

        handoffReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                String sendingPage = intent.getStringExtra(getString(R.string.app_cms_closing_page_name));

                if (intent.getAction().equals(AppCMSPresenter.PRESENTER_NAVIGATE_ACTION)) {
                    Bundle args = intent.getBundleExtra(getString(R.string.app_cms_bundle_key));
                    if ((((AppCMSBinder) args.getBinder(getString(R.string.app_cms_binder_key))).getExtraScreenType() ==
                            AppCMSPresenter.ExtraScreenType.EDIT_PROFILE)) {
                        AppCMSBinder binder = (AppCMSBinder) args.getBinder(getString(R.string.app_cms_binder_key));
                        if (binder.getPageName().equalsIgnoreCase(getString(R.string.app_cms_sign_up_pager_title))) {
                            openSignUpDialog(intent, true);
                        } else {
                            openLoginDialog(intent, true);
                        }
                    } else if ((((AppCMSBinder) args.getBinder(getString(R.string.app_cms_binder_key))).getExtraScreenType() ==
                            AppCMSPresenter.ExtraScreenType.TERM_OF_SERVICE)) {
                        openGenericDialog(intent, false);
                    }
                } else if (intent.getAction().equals(AppCMSPresenter.CLOSE_DIALOG_ACTION)) {
                    closeSignInDialog();
                    closeSignUpDialog();
                    //  appCMSPlayVideoFragment.resumeVideo();
                    appCMSPresenter.getUserData(
                            userIdentity -> {
                                if (null != userIdentity) {
                                    if (userIdentity.isSubscribed()) {
                                        appCMSPlayVideoFragment.resumeVideo();
                                    } else {

                                        String dialogMessage = getString(R.string.unsubscribe_text);
                                        if (appCMSPresenter.getAppCMSAndroid() != null
                                                && appCMSPresenter.getAppCMSAndroid().getSubscriptionFlowContent() != null) {
                                            if (appCMSPresenter.getAppCMSAndroid().getSubscriptionFlowContent().getOverlayMessage() != null) {
                                                dialogMessage = appCMSPresenter.getAppCMSAndroid().getSubscriptionFlowContent().getOverlayMessage();
                                            }
                                        }

                                        ClearDialogFragment newFragment = Utils.getClearDialogFragment(
                                                AppCMSTVPlayVideoActivity.this,
                                                appCMSPresenter,
                                                getResources().getDimensionPixelSize(R.dimen.text_clear_dialog_width),
                                                getResources().getDimensionPixelSize(R.dimen.text_add_to_watchlist_sign_in_dialog_height),
                                                getString(R.string.subscription_required),
                                                dialogMessage,
                                                getString(android.R.string.cancel),
                                                getString(R.string.blank_string),
                                                14
                                        );
                                        newFragment.setOnPositiveButtonClicked(new Action1<String>() {
                                            @Override
                                            public void call(String s) {
                                                finish();
                                            }
                                        });
                                    }
                                }
                            }
                    );
                    Utils.pageLoading(false, AppCMSTVPlayVideoActivity.this);
                } else if (intent.getAction().equals(AppCMSPresenter.ACTION_RESET_PASSWORD)) {
                    openResetPasswordScreen(intent);
                } else if (intent.getAction().equals(AppCMSPresenter.ERROR_DIALOG_ACTION)) {
                    openErrorDialog(intent);
                } else if (intent.getAction().equals(AppCMSPresenter.PRESENTER_PAGE_LOADING_ACTION)) {
                    Utils.pageLoading(true, AppCMSTVPlayVideoActivity.this);
                } else if (intent.getAction().equals(AppCMSPresenter.PRESENTER_STOP_PAGE_LOADING_ACTION)) {
                    Utils.pageLoading(false, AppCMSTVPlayVideoActivity.this);
                } else if (intent.getBooleanExtra(getString(R.string.close_self_key), true) &&
                        (sendingPage == null || getString(R.string.app_cms_video_page_tag).equals(sendingPage))) {

                }
            }
        };

        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
    }
    private void initializeStreamingQualityValues(VideoAssets videoAssets) {
        if (availableStreamingFormats == null) {
            availableStreamingFormats = new HashMap<>();
        }
        if (videoAssets != null && videoAssets.getMpeg() != null) {
            List<Mpeg> availableMpegs = videoAssets.getMpeg();
            int numAvailableMpegs = availableMpegs.size();
            for (int i = 0; i < numAvailableMpegs; i++) {
                Mpeg availableMpeg = availableMpegs.get(i);
                String mpegUrl = availableMpeg.getUrl();
                if (!TextUtils.isEmpty(mpegUrl)) {
                    String resolution = getMpegResolutionFromUrl(mpegUrl);
                    if (!TextUtils.isEmpty(resolution)) {
                        availableStreamingFormats.put(resolution, availableMpeg.getUrl());
                    }
                }
            }
        }
    }
    private void launchVideoPlayer(Gist gist , AppCMSSignedURLResult appCMSSignedURLResult) {
        String videoUrl = "";
        String closedCaptionUrl = null;
        title = gist.getTitle();
        String fontColor = binder.getFontColor();
        boolean useHls = getResources().getBoolean(R.bool.use_hls);
        String defaultVideoResolution = getString(R.string.default_video_resolution);
        if (binder.getContentData() != null &&
                binder.getContentData().getStreamingInfo() != null &&
                binder.getContentData().getStreamingInfo().getVideoAssets() != null) {
            VideoAssets videoAssets = binder.getContentData().getStreamingInfo().getVideoAssets();

            initializeStreamingQualityValues(videoAssets);

            if (useHls) {
                videoUrl = videoAssets.getHls();
            }
            if (TextUtils.isEmpty(videoUrl)) {
                if (videoAssets.getMpeg() != null && !videoAssets.getMpeg().isEmpty()) {
                    if (videoAssets.getMpeg().get(0) != null) {
                        videoUrl = videoAssets.getMpeg().get(0).getUrl();
                    }
                    for (int i = 0; i < videoAssets.getMpeg().size() /*&& TextUtils.isEmpty(videoUrl)*/; i++) {
                        if (videoAssets.getMpeg().get(i) != null &&
                                videoAssets.getMpeg().get(i).getRenditionValue() != null &&
                                videoAssets.getMpeg().get(i).getRenditionValue().contains(defaultVideoResolution)) {
                            videoUrl = videoAssets.getMpeg().get(i).getUrl();
                        }
                    }
                }
            }

            if (useHls && videoAssets.getMpeg() != null && videoAssets.getMpeg().size() > 0) {
                if (videoAssets.getMpeg().get(0).getUrl() != null &&
                        videoAssets.getMpeg().get(0).getUrl().indexOf("?") > 0) {
                    videoUrl = videoUrl + videoAssets.getMpeg().get(0).getUrl().substring(videoAssets.getMpeg().get(0).getUrl().indexOf("?"));
                }
            }
        }

        // TODO: 7/27/2017 Implement CC for multiple languages.
        if (binder.getContentData() != null
                && binder.getContentData().getContentDetails() != null
                && binder.getContentData().getContentDetails().getClosedCaptions() != null
                && !binder.getContentData().getContentDetails().getClosedCaptions().isEmpty()) {
            for (ClosedCaptions cc : binder.getContentData().getContentDetails().getClosedCaptions()) {
                if (cc.getUrl() != null &&
                        !cc.getUrl().equalsIgnoreCase(getString(R.string.download_file_prefix)) &&
                        cc.getFormat() != null &&
                        cc.getFormat().equalsIgnoreCase("SRT")) {
                    closedCaptionUrl = cc.getUrl();
                }
            }
        }
        String permaLink = gist.getPermalink();
        hlsUrl = videoUrl;
        videoImageUrl = gist.getVideoImageUrl();
        filmId = binder.getContentData().getGist().getId();
        String adsUrl = binder.getAdsUrl();
        String bgColor = binder.getBgColor();
        int playIndex = binder.getCurrentPlayingVideoIndex();
        long watchedTime = binder.getContentData().getGist().getWatchedTime();
        if (gist.getPrimaryCategory() != null && gist.getPrimaryCategory().getTitle() != null)
            primaryCategory = gist.getPrimaryCategory().getTitle();
        boolean playAds = binder.isPlayAds();
        relateVideoIds = binder.getRelateVideoIds();
        currentlyPlayingIndex = binder.getCurrentPlayingVideoIndex();

        /*if (!TextUtils.isEmpty(bgColor)) {
            appCMSPlayVideoPageContainer.setBackgroundColor(Color.parseColor(bgColor));
        }*/

        boolean freeContent = false;
        if (binder.getContentData() != null && binder.getContentData().getGist() != null &&
                binder.getContentData().getGist().getFree()) {
            freeContent = binder.getContentData().getGist().getFree();
        }

        FragmentManager fragmentManager = getFragmentManager();
        FragmentTransaction fragmentTransaction = fragmentManager.beginTransaction();
//        hlsUrl = "https://vhoichoi.viewlift.com/encodes/trailers/byomkesh_s2_trailer_high.mp4?Policy=eyJTdGF0ZW1lbnQiOiBbeyJSZXNvdXJjZSI6Imh0dHBzOi8vdmhvaWNob2kudmlld2xpZnQuY29tL2VuY29kZXMvdHJhaWxlcnMvYnlvbWtlc2hfczJfdHJhaWxlcl9oaWdoLm1wNCIsIkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTUxNTU4NTYwOX0sIklwQWRkcmVzcyI6eyJBV1M6U291cmNlSXAiOiIwLjAuMC4wLzAifX19XX0_&Signature=e-Vle9RV0LOcr7JkuK1fqlhAld0Ef5W3kRH798f8YOaKT~JUCXtLdx9UcO2McXuqi4jyNWiis9OEcJqNFMPUIIZYBxa78lRH9rvzstPOPPSpk6wErymPiwey2ZWUq1E1vog6a7MwjzeWTEuyCLw6ZEXt~hyd2DGO3z3PM5E0U8HuhrcW9VcO2lgya9A5BFZidwmVnAu4VKLyUQKY1~LQImS7vqo8Va0zGl7LkglpZCEIbWZCgcVsOtI4SJBaWY8oNaA34XebfOnhhons8-LWM1hOY0dCmcr1NgIFaJveiFCqctA3qY~5IjAmXV7s6Ddahp69yHcNDwg2SuTmDE~reA__&Key-Pair-Id=APKAISSG7ZCPKHJZAD4Q";
        appCMSPlayVideoFragment =
                AppCMSPlayVideoFragment.newInstance(this,
                        null,
                        fontColor,
                        title,
                        permaLink,
                        binder.isTrailer(),
                        hlsUrl,
                        filmId,
                        adsUrl,
                        playAds,
                        playIndex,
                        watchedTime,
                        binder.getContentData().getGist().getRuntime(),
                        null,
                        closedCaptionUrl,
                        binder.getContentData().getParentalRating(),
                        freeContent,
                        appCMSSignedURLResult,
                        binder.getContentData());
        fragmentTransaction.add(R.id.app_cms_play_video_page_container,
                appCMSPlayVideoFragment,
                getString(R.string.video_fragment_tag_key));
        fragmentTransaction.addToBackStack(getString(R.string.video_fragment_tag_key));
        fragmentTransaction.commit();
    }

    /**
     * Method is used to find and return to-be-played url. Based on the selection and availability,
     * the method computes the HLS or MP4 url of a particular movie.
     *
     * @param videoAssets assets in which all the url data is present
     * @return to-be-played url
     */
    @Nullable
    private String getVideoUrl(VideoAssets videoAssets) {
        boolean useHls = getResources().getBoolean(R.bool.use_hls);
        String defaultVideoResolution = getString(R.string.default_video_resolution);
        String videoUrl = null;
        if (useHls) {
            videoUrl = videoAssets.getHls();
        }
        if (TextUtils.isEmpty(videoUrl)) {
            if (videoAssets.getMpeg() != null && !videoAssets.getMpeg().isEmpty()) {

                for (int i = 0; i < videoAssets.getMpeg().size() && TextUtils.isEmpty(videoUrl); i++) {
                    if (videoAssets.getMpeg().get(i) != null &&
                            videoAssets.getMpeg().get(i).getRenditionValue() != null &&
                            videoAssets.getMpeg().get(i).getRenditionValue().contains(defaultVideoResolution)) {
                        videoUrl = videoAssets.getMpeg().get(i).getUrl();
                    }
                }
                if (videoAssets.getMpeg().get(0) != null && TextUtils.isEmpty(videoUrl)) {
                    videoUrl = videoAssets.getMpeg().get(0).getUrl();
                }
            }
        }
        return videoUrl;
    }


    AppCmsLoginDialogFragment loginDialog;
    AppCmsSignUpDialogFragment signUpDialog;

    private void openLoginDialog(Intent intent, boolean isLoginPage) {
        if (null != intent) {
            Bundle bundle = intent.getBundleExtra(getString(R.string.app_cms_bundle_key));
            if (null != bundle) {
                AppCMSBinder appCMSBinder = (AppCMSBinder) bundle.get(getString(R.string.app_cms_binder_key));
                bundle.putBoolean("isLoginPage", isLoginPage);
                FragmentTransaction ft = getFragmentManager().beginTransaction();
                loginDialog = AppCmsLoginDialogFragment.newInstance(
                        appCMSBinder);
                loginDialog.show(ft, "DIALOG_FRAGMENT_TAG");

                loginDialog.setBackKeyListener(new Action1<String>() {
                    @Override
                    public void call(String s) {
                        appCMSPlayVideoFragment.cancelTimer();
                        finish();
                    }
                });
            }
        }
    }

    private void openSignUpDialog(Intent intent, boolean isLoginPage) {
        if (null != intent) {
            Bundle bundle = intent.getBundleExtra(getString(R.string.app_cms_bundle_key));
            if (null != bundle) {
                AppCMSBinder appCMSBinder = (AppCMSBinder) bundle.get(getString(R.string.app_cms_binder_key));
                bundle.putBoolean("isLoginPage", isLoginPage);
                FragmentTransaction ft = getFragmentManager().beginTransaction();
                signUpDialog = AppCmsSignUpDialogFragment.newInstance(
                        appCMSBinder);
                signUpDialog.show(ft, "DIALOG_FRAGMENT_TAG");

                signUpDialog.setBackKeyListener(new Action1<String>() {
                    @Override
                    public void call(String s) {
                        appCMSPlayVideoFragment.cancelTimer();
                        finish();
                    }
                });

            }
        }
    }

    public void closeSignUpDialog() {
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                if (signUpDialog != null) {
                    signUpDialog.dismiss();
                    signUpDialog = null;
                }
            }
        }, 50);

    }

    public void closeSignInDialog() {
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                if (loginDialog != null) {
                    loginDialog.dismiss();
                    loginDialog = null;
                }
            }
        }, 50);

    }


    private void openResetPasswordScreen(Intent intent) {
        if (null != intent) {

            Bundle bundle = intent.getBundleExtra(getString(R.string.app_cms_bundle_key));
            if (null != bundle) {
                AppCMSBinder appCMSBinder = (AppCMSBinder) bundle.get(getString(R.string.app_cms_binder_key));
                FragmentTransaction ft = getFragmentManager().beginTransaction();
                appCmsResetPasswordFragment = AppCmsResetPasswordFragment.newInstance(
                        appCMSBinder);
                appCmsResetPasswordFragment.show(ft, "DIALOG_FRAGMENT_TAG");
                Utils.pageLoading(false, AppCMSTVPlayVideoActivity.this);
            }
        }
    }


    private void openErrorDialog(Intent intent) {
        Bundle bundle = intent.getBundleExtra(getString(R.string.retryCallBundleKey));
        bundle.putBoolean(getString(R.string.retry_key), bundle.getBoolean(getString(R.string.retry_key)));
        bundle.putBoolean(getString(R.string.register_internet_receiver_key), bundle.getBoolean(getString(R.string.register_internet_receiver_key)));
        bundle.putString(getString(R.string.tv_dialog_msg_key), bundle.getString(getString(R.string.tv_dialog_msg_key)));
        bundle.putString(getString(R.string.tv_dialog_header_key), bundle.getString(getString(R.string.tv_dialog_header_key)));

        FragmentTransaction ft = getFragmentManager().beginTransaction();
        AppCmsTvErrorFragment newFragment = AppCmsTvErrorFragment.newInstance(
                bundle);
        newFragment.setErrorListener(this);
        newFragment.show(ft, "DIALOG_FRAGMENT_TAG");
        Utils.pageLoading(false, AppCMSTVPlayVideoActivity.this);
    }


    private void openGenericDialog(Intent intent, boolean isLoginPage) {
        if (null != intent) {
            Bundle bundle = intent.getBundleExtra(getString(R.string.app_cms_bundle_key));
            if (null != bundle) {
                AppCMSBinder appCMSBinder = (AppCMSBinder) bundle.get(getString(R.string.app_cms_binder_key));
                bundle.putBoolean("isLoginPage", isLoginPage);
                FragmentTransaction ft = getFragmentManager().beginTransaction();
                AppCmsGenericDialogFragment newFragment = AppCmsGenericDialogFragment.newInstance(
                        appCMSBinder);
                newFragment.show(ft, "DIALOG_FRAGMENT_TAG");
                Utils.pageLoading(false, this);
            }
        }


    }


    @Override
    protected void onResume() {
        super.onResume();
        registerRecievers();
        appCMSPresenter.setCancelAllLoads(false);
        if (!appCMSPresenter.isNetworkConnected()) {
            // appCMSPresenter.showErrorDialog(AppCMSPresenter.Error.NETWORK, null); //TODO : need to show error dialog.
            finish();
        }
    }

    private void registerRecievers() {
        registerReceiver(handoffReceiver, new IntentFilter(AppCMSPresenter.PRESENTER_CLOSE_SCREEN_ACTION));
        registerReceiver(handoffReceiver, new IntentFilter(AppCMSPresenter.PRESENTER_NAVIGATE_ACTION));
        registerReceiver(handoffReceiver, new IntentFilter(AppCMSPresenter.CLOSE_DIALOG_ACTION));
        registerReceiver(handoffReceiver, new IntentFilter(AppCMSPresenter.ACTION_RESET_PASSWORD));
        registerReceiver(handoffReceiver, new IntentFilter(AppCMSPresenter.ERROR_DIALOG_ACTION));
        registerReceiver(handoffReceiver, new IntentFilter(AppCMSPresenter.PRESENTER_PAGE_LOADING_ACTION));
        registerReceiver(handoffReceiver, new IntentFilter(AppCMSPresenter.PRESENTER_STOP_PAGE_LOADING_ACTION));
    }

    @Override
    protected void onPause() {
        unregisterReceiver(handoffReceiver);
        super.onPause();
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        Intent returnIntent = new Intent();
        setResult(Activity.RESULT_OK, returnIntent);
        finish();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }

    @Override
    public void closePlayer() {
        finish();
    }

    @Override
    public boolean dispatchKeyEvent(KeyEvent event) {

        boolean result = false;
        if (event.getAction() == KeyEvent.ACTION_DOWN) {
            if (null != appCMSPlayVideoFragment) {
                if (appCMSPlayVideoFragment.isAdsPlaying()) {
                    if (event.getKeyCode() != KeyEvent.KEYCODE_BACK) {
                        return true;
                    }
                } else {
                    appCMSPlayVideoFragment.showController(event);
                }
            }

            switch (event.getKeyCode()) {
                case KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE:
                    if (null != appCMSPlayVideoPageContainer) {
                        appCMSPlayVideoPageContainer.findViewById(R.id.exo_pause).requestFocus();
                        appCMSPlayVideoPageContainer.findViewById(R.id.exo_play).requestFocus();
                        if (appCMSPlayVideoFragment != null
                                && appCMSPlayVideoFragment.getVideoPlayerView() != null
                                && appCMSPlayVideoFragment.getVideoPlayerView().getPlayerView() != null) {
                            return super.dispatchKeyEvent(event)
                                    || appCMSPlayVideoFragment.getVideoPlayerView().getPlayerView()
                                    .dispatchKeyEvent(event);
                        }
                    }
                    break;
                case KeyEvent.KEYCODE_MEDIA_REWIND:
                    if (null != appCMSPlayVideoPageContainer) {
                        appCMSPlayVideoPageContainer.findViewById(R.id.exo_rew).requestFocus();
                        return super.dispatchKeyEvent(event);
                    }
                    break;
                case KeyEvent.KEYCODE_MEDIA_FAST_FORWARD:
                    if (null != appCMSPlayVideoPageContainer) {
                        appCMSPlayVideoPageContainer.findViewById(R.id.exo_ffwd).requestFocus();
                        return super.dispatchKeyEvent(event);
                    }
                    break;
            }
        }
        return super.dispatchKeyEvent(event);
    }

    @Override
    public void onPointerCaptureChanged(boolean hasCapture) {

    }

    @Override
    public void onMovieFinished() {
        if (appCMSPresenter.getAutoplayEnabledUserPref(getApplication())) {
            if (!binder.isTrailer()
                    && relateVideoIds != null
                    && currentlyPlayingIndex + 1 < relateVideoIds.size()) {
                binder.setCurrentPlayingVideoIndex(currentlyPlayingIndex);
                appCMSPresenter.openAutoPlayScreen(binder, new Action1<Object>() {
                    @Override
                    public void call(Object o) {
                        closePlayer();
                    }
                });
            } else {
                closePlayer();
            }
        } else {
            closePlayer();
        }
    }

    @Override
    public void onErrorScreenClose() {

    }

    @Override
    public void onRetry(Bundle bundle) {

    }

    @Override
    protected void onStop() {
        super.onStop();
        if (appCMSPlayVideoFragment != null) {
            appCMSPlayVideoFragment.cancelTimer();
        }
    }

    @Override
    public List<String> getAvailableStreamingQualities() {
        return new ArrayList<>(availableStreamingFormats.keySet());
    }

    @Override
    public String getStreamingQualityUrl(String streamingQuality) {
        if (availableStreamingFormats != null && availableStreamingFormats.containsKey(streamingQuality)) {
            return availableStreamingFormats.get(streamingQuality);
        }
        return null;
    }

    @Override
    public String getMpegResolutionFromUrl(String mpegUrl) {
        if (mpegUrl != null) {
            int mpegIndex = mpegUrl.indexOf(".mp4");
            if (0 < mpegIndex) {
                int startIndex = mpegUrl.substring(0, mpegIndex).lastIndexOf("/");
                if (0 <= startIndex && startIndex < mpegIndex) {
                    return mpegUrl.substring(startIndex + 1, mpegIndex);
                }
            }
        }
        return null;
    }

    @Override
    public int getMpegResolutionIndexFromUrl(String mpegUrl) {
        return 0;
    }
}
