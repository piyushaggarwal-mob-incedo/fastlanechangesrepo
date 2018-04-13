package com.viewlift.views.adapters;

import android.annotation.SuppressLint;
import android.app.ProgressDialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Entity;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Color;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffColorFilter;
import android.os.Handler;
import android.support.annotation.NonNull;
import android.support.v4.content.ContextCompat;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.ImageView;

import com.viewlift.Audio.AudioServiceHelper;
import com.viewlift.Audio.model.MusicLibrary;
import com.viewlift.Audio.playback.AudioPlaylistHelper;
import com.viewlift.R;
import com.viewlift.models.data.appcms.api.AppCMSPageAPI;
import com.viewlift.models.data.appcms.api.ContentDatum;
import com.viewlift.models.data.appcms.api.Module;
import com.viewlift.models.data.appcms.audio.AppCMSAudioDetailResult;
import com.viewlift.models.data.appcms.downloads.DownloadStatus;
import com.viewlift.models.data.appcms.downloads.DownloadVideoRealm;
import com.viewlift.models.data.appcms.downloads.UserVideoDownloadStatus;
import com.viewlift.models.data.appcms.ui.AppCMSUIKeyType;
import com.viewlift.models.data.appcms.ui.android.AppCMSAndroidModules;
import com.viewlift.models.data.appcms.ui.page.Component;
import com.viewlift.models.data.appcms.ui.page.Layout;
import com.viewlift.models.data.appcms.ui.page.Settings;
import com.viewlift.presenters.AppCMSPresenter;
import com.viewlift.views.customviews.BaseView;
import com.viewlift.views.customviews.CollectionGridItemView;
import com.viewlift.views.customviews.InternalEvent;
import com.viewlift.views.customviews.OnInternalEvent;
import com.viewlift.views.customviews.ViewCreator;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import rx.functions.Action1;

/*
 * Created by viewlift on 5/5/17.
 */

public class AppCMSPlaylistAdapter extends RecyclerView.Adapter<AppCMSPlaylistAdapter.ViewHolder>
        implements AppCMSBaseAdapter, OnInternalEvent {
    private static final String TAG = AppCMSPlaylistAdapter.class.getSimpleName() + "TAG";
    protected Context mContext;
    protected Layout parentLayout;
    protected Component component;
    protected AppCMSPresenter appCMSPresenter;
    protected Settings settings;
    protected ViewCreator viewCreator;
    protected Map<String, AppCMSUIKeyType> jsonValueKeyMap;
    private ProgressDialog progressDialog;
    Module moduleAPI;
    List<ContentDatum> adapterData;
    CollectionGridItemView.OnClickHandler onClickHandler;
    int defaultWidth;
    int defaultHeight;
    boolean useMarginsAsPercentages;
    String componentViewType;
    AppCMSAndroidModules appCMSAndroidModules;
    private boolean useParentSize;
    private AppCMSUIKeyType viewTypeKey;
    private boolean isClickable;

    private List<OnInternalEvent> receivers;
    private String mCurrentPlayListId;

    private String moduleId;
    RecyclerView mRecyclerView;
    String downloadAudioAction;
    CollectionGridItemView[] allViews;
    public static boolean isDownloading = true, isPlaylistDownloading = false;
    private Map<String, Boolean> filmDownloadIconUpdatedMap;

    updateDataReceiver serviceReceiver;

    public AppCMSPlaylistAdapter(Context context,
                                 ViewCreator viewCreator,
                                 AppCMSPresenter appCMSPresenter,
                                 Settings settings,
                                 Layout parentLayout,
                                 boolean useParentSize,
                                 Component component,
                                 Map<String, AppCMSUIKeyType> jsonValueKeyMap,
                                 Module moduleAPI,
                                 int defaultWidth,
                                 int defaultHeight,
                                 String viewType,
                                 AppCMSAndroidModules appCMSAndroidModules) {
        this.mContext = context;
        this.viewCreator = viewCreator;
        this.appCMSPresenter = appCMSPresenter;
        this.parentLayout = parentLayout;
        this.useParentSize = useParentSize;
        this.component = component;
        this.jsonValueKeyMap = jsonValueKeyMap;
        this.moduleAPI = moduleAPI;
        this.receivers = new ArrayList<>();
        this.downloadAudioAction = getDownloadAudioAction(context);
        this.adapterData = new ArrayList<>();
        this.filmDownloadIconUpdatedMap = new HashMap<>();
        if (moduleAPI != null && moduleAPI.getContentData() != null) {
            adapterData.addAll(moduleAPI.getContentData());
            if (moduleAPI.getContentData().get(0).getGist() != null) {
                mCurrentPlayListId = moduleAPI.getContentData().get(0).getGist().getId();
            }
            /*removing 1st data in the list since it contains playlist GIST*/
            if (moduleAPI.getContentData().get(0).getGist() != null &&
                    moduleAPI.getContentData().get(0).getGist().getMediaType() != null
                    && moduleAPI.getContentData().get(0).getGist().getMediaType().toLowerCase().contains(context.getString(R.string.media_type_playlist).toLowerCase())) {
                adapterData.remove(0);
            }
            allViews = new CollectionGridItemView[this.adapterData.size()];
        }
        this.componentViewType = viewType;
        this.viewTypeKey = jsonValueKeyMap.get(componentViewType);
        if (this.viewTypeKey == null) {
            this.viewTypeKey = AppCMSUIKeyType.PAGE_EMPTY_KEY;
        }

        this.defaultWidth = defaultWidth;
        this.defaultHeight = defaultHeight;
        this.useMarginsAsPercentages = true;
        this.isClickable = true;
        this.setHasStableIds(false);
        this.appCMSAndroidModules = appCMSAndroidModules;
        serviceReceiver = new updateDataReceiver();



    }
    private void progressDialogInit(){
        progressDialog = new ProgressDialog(mContext,R.style.AppCMSProgressDialogStyle);


        //Set the progress dialog to display a horizontal progress bar
        progressDialog.setProgressStyle(ProgressDialog.STYLE_HORIZONTAL);
        //Set the dialog title to 'Loading...'
        progressDialog.setTitle("Download Playlist...");
        //Set the dialog message to 'Loading application View, please wait...'
        progressDialog.setMessage("Adding playlist in download queue, please wait...");
        //This dialog can't be canceled by pressing the back key
        progressDialog.setCancelable(false);
        //This dialog isn't indeterminate
        progressDialog.setIndeterminate(false);
        //The maximum number of items is 100
        progressDialog.setMax(adapterData.size());
        //Set the current progress to zero
        progressDialog.setProgress(countDownloadPlaylist);
        progressDialog.show();
    }

    @Override
    public void onAttachedToRecyclerView(RecyclerView recyclerView) {
        super.onAttachedToRecyclerView(recyclerView);
        mRecyclerView = recyclerView;

        if (mContext != null) {
            IntentFilter intentFilter = new IntentFilter();
            intentFilter.addAction(AudioServiceHelper.APP_CMS_UPDATE_PLAYLIST);
            mContext.registerReceiver(serviceReceiver, intentFilter);
        }
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        CollectionGridItemView view = viewCreator.createCollectionGridItemView(parent.getContext(),
                parentLayout,
                useParentSize,
                component,
                appCMSPresenter,
                moduleAPI,
                appCMSAndroidModules,
                settings,
                jsonValueKeyMap,
                defaultWidth,
                defaultHeight,
                useMarginsAsPercentages,
                true,
                this.componentViewType,
                false,
                false,
                viewTypeKey);
        view.setLayoutParams(new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
        mRecyclerView.getRecycledViewPool().setMaxRecycledViews(viewType, adapterData.size());
        return new ViewHolder(view);
    }


    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {
        if (0 <= position && position < adapterData.size()) {
            allViews[position] = holder.componentView;
            bindView(holder.componentView, adapterData.get(position), position);
            // downloadView(adapterData.get(position), holder.componentView);
            if (AudioPlaylistHelper.getInstance().getCurrentAudioPLayingData() != null) {
                if (adapterData.get(position).getGist().getId().equalsIgnoreCase(AudioPlaylistHelper.getInstance().getCurrentAudioPLayingData().getGist().getId()) && AudioPlaylistHelper.getInstance().getCurrentMediaId() != null) {
                    adapterData.get(position).getGist().setAudioPlaying(true);
                } else {
                    adapterData.get(position).getGist().setAudioPlaying(false);
                }
            }

            if (adapterData.get(position).getGist().isAudioPlaying()) {
                holder.componentView.setBackgroundColor(Color.parseColor("#4B0502"));
            } else {
                holder.componentView.setBackgroundColor(ContextCompat.getColor(mContext, android.R.color.transparent));
            }
            holder.componentView.setTag((position));
            holder.componentView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    try {
                        int clickPosition = (int) view.getTag();
                        ContentDatum data = adapterData.get(position);
                        playPlaylistItem(data, view, clickPosition);

                    } catch (ArrayIndexOutOfBoundsException e) {
                        e.printStackTrace();
                    }
                }
            });
        }
    }

    private void downloadView(ContentDatum contentDatum, CollectionGridItemView componentView) {
        String userId = appCMSPresenter.getLoggedInUser();
        ImageButton playlistDownloadButton = null;
        for (int i = 0; i < componentView.getChildItems().size(); i++) {
            CollectionGridItemView.ItemContainer itemContainer = componentView.getChildItems().get(i);
            if (itemContainer.getComponent().getKey() != null) {
                if (itemContainer.getComponent().getKey().contains(mContext.getString(R.string.app_cms_page_audio_download_button_key))) {
                    playlistDownloadButton = (ImageButton) itemContainer.getChildView();
                }
            }
        }
        if (playlistDownloadButton != null) {
            int radiusDifference = 5;
            if (BaseView.isTablet(componentView.getContext())) {
                radiusDifference = 2;
            }
            if (contentDatum.getGist() != null) {
//                playlistDownloadButton.setTag(contentDatum.getGist().getId());
                final ImageButton downloadButton = playlistDownloadButton;
                appCMSPresenter.getUserVideoDownloadStatus(contentDatum.getGist().getId(),
                        videoDownloadStatus -> {
                            if (videoDownloadStatus != null &&
                                    (videoDownloadStatus.getDownloadStatus() == DownloadStatus.STATUS_PAUSED ||
                                            videoDownloadStatus.getDownloadStatus() == DownloadStatus.STATUS_PENDING ||
                                            (!appCMSPresenter.isNetworkConnected() &&
                                                    videoDownloadStatus.getDownloadStatus() != DownloadStatus.STATUS_COMPLETED &&
                                                    videoDownloadStatus.getDownloadStatus() != DownloadStatus.STATUS_SUCCESSFUL))) {
                                downloadButton.setImageBitmap(null);
                                downloadButton.setBackground(ContextCompat.getDrawable(componentView.getContext(),
                                        R.drawable.ic_download_queued));
                            }
                        },
                        appCMSPresenter.getLoggedInUser());

                switch (contentDatum.getGist().getDownloadStatus()) {
                    case STATUS_PENDING:
                    case STATUS_RUNNING:
                        if (contentDatum.getGist() != null && playlistDownloadButton != null) {
                            if (playlistDownloadButton.getBackground() != null) {
                                playlistDownloadButton.getBackground().setTint(ContextCompat.getColor(mContext, R.color.transparentColor));
                                playlistDownloadButton.getBackground().setTintMode(PorterDuff.Mode.MULTIPLY);
                            }

                            ImageButton finalplaylistDownloadButton = playlistDownloadButton;

                            Log.e(TAG, "Audio downloading: " + contentDatum.getGist().getId());

                            Boolean filmDownloadUpdated = filmDownloadIconUpdatedMap.get(contentDatum.getGist().getId());
                            if (filmDownloadUpdated == null || !filmDownloadUpdated) {
                                filmDownloadIconUpdatedMap.put(contentDatum.getGist().getId(), true);

                                appCMSPresenter.updateDownloadingStatus(contentDatum.getGist().getId(),
                                        playlistDownloadButton,
                                        appCMSPresenter,
                                        userVideoDownloadStatus -> {
                                            if (userVideoDownloadStatus != null) {
                                                if (userVideoDownloadStatus.getDownloadStatus() == DownloadStatus.STATUS_SUCCESSFUL) {
                                                    finalplaylistDownloadButton.setImageBitmap(null);
                                                    finalplaylistDownloadButton.setBackground(ContextCompat.getDrawable(mContext, R.drawable.ic_downloaded_big));
                                                    finalplaylistDownloadButton.invalidate();

                                                    contentDatum.getGist().setLocalFileUrl(userVideoDownloadStatus.getVideoUri());
                                                    try {
                                                        if (userVideoDownloadStatus.getSubtitlesUri().trim().length() > 10 &&
                                                                contentDatum.getContentDetails() != null &&
                                                                contentDatum.getContentDetails().getClosedCaptions().get(0) != null) {
                                                            contentDatum.getContentDetails().getClosedCaptions().get(0).setUrl(userVideoDownloadStatus.getSubtitlesUri());
                                                        }
                                                    } catch (Exception e) {
                                                        //Log.e(TAG, e.getMessage());
                                                    }

                                                }
                                                contentDatum.getGist().setDownloadStatus(userVideoDownloadStatus.getDownloadStatus());
                                            }
                                        },
                                        userId, true, radiusDifference, appCMSPresenter.getDownloadPageId());
                            } else {
                                appCMSPresenter.updateDownloadTimerTask(contentDatum.getGist().getId(),
                                        appCMSPresenter.getDownloadPageId(),
                                        playlistDownloadButton);
                            }

                        }
                        break;


                    case STATUS_SUCCESSFUL:
                        Log.e(TAG, "Audio download successful: " + contentDatum.getGist().getId());
                        playlistDownloadButton.setImageBitmap(null);
                        playlistDownloadButton.setBackground(ContextCompat.getDrawable(mContext,
                                R.drawable.ic_downloaded_big));
                        contentDatum.getGist().setDownloadStatus(DownloadStatus.STATUS_COMPLETED);
                        break;


                    default:
                        Log.e(TAG, "Audio download status unknown: " + contentDatum.getGist().getId());

                        break;
                }
                DownloadVideoRealm downloadVideoRealm = appCMSPresenter.getRealmController()
                        .getDownloadByIdBelongstoUser(contentDatum.getGist().getId(), userId);
                if (downloadVideoRealm != null && contentDatum != null && contentDatum.getGist() != null) {
                    if (downloadVideoRealm.getWatchedTime() > contentDatum.getGist().getWatchedTime()) {
                        contentDatum.getGist().setWatchedTime(downloadVideoRealm.getWatchedTime());
                    }
                }
            }
        }
    }

    @Override
    public int getItemCount() {
        return (adapterData != null ? adapterData.size() : 0);
    }

    @Override
    public void resetData(RecyclerView listView) {
        notifyDataSetChanged();
    }

    @Override
    public void updateData(RecyclerView listView, List<ContentDatum> contentData) {
        listView.setAdapter(null);
        adapterData = null;
        notifyDataSetChanged();
        adapterData = contentData;
        notifyDataSetChanged();
        listView.setAdapter(this);
        listView.invalidate();
        notifyDataSetChanged();

    }

    static int oldClick = -1;

    @SuppressLint("ClickableViewAccessibility")
    void bindView(CollectionGridItemView itemView,
                  final ContentDatum data, int position) throws IllegalArgumentException {
        if (onClickHandler == null) {
            if (viewTypeKey == AppCMSUIKeyType.PAGE_PLAYLIST_MODULE_KEY) {
                onClickHandler = new CollectionGridItemView.OnClickHandler() {
                    @Override
                    public void click(CollectionGridItemView collectionGridItemView,
                                      Component childComponent,
                                      ContentDatum data, int clickPosition) {
                        try {
                            System.out.println("playlist adapter on click-");

                            isDownloading = true;
                            if (isClickable) {
                                if (data.getGist() != null) {
                                    String action = null;
                                    if (childComponent != null && !TextUtils.isEmpty(childComponent.getAction())) {
                                        action = childComponent.getAction();
                                    }
                                    if (action != null && action.contains(downloadAudioAction)) {
                                        ImageButton download = null;
                                        for (int i = 0; i < collectionGridItemView.getChildItems().size(); i++) {
                                            CollectionGridItemView.ItemContainer itemContainer = collectionGridItemView.getChildItems().get(i);
                                            if (itemContainer.getComponent().getKey() != null) {
                                                if (itemContainer.getComponent().getKey().contains(mContext.getString(R.string.app_cms_page_audio_download_button_key))) {
                                                    download = (ImageButton) itemContainer.getChildView();
                                                    //download.setTag(true);
                                                }
                                            }
                                        }
                                        audioDownload(download, data, true);
                                        return;
                                    }
                                    if (action == null) {
                                        if (!appCMSPresenter.isNetworkConnected()) {
                                            appCMSPresenter.openDownloadScreenForNetworkError(false,
                                                    () -> playPlaylistItem(data, itemView, clickPosition));
                                            return;
                                        }
                                        /*get audio details on tray click item and play song*/
                                        playPlaylistItem(data, itemView, clickPosition);
                                    }
                                }
                            }
                        } catch (ArrayIndexOutOfBoundsException e) {
                            e.printStackTrace();
                        }
                    }

                    @Override
                    public void play(Component childComponent, ContentDatum data) {
                    }
                };

            }
        }

        for (int i = 0; i < itemView.getNumberOfChildren(); i++) {
            itemView.bindChild(itemView.getContext(),
                    itemView.getChild(i),
                    data,
                    jsonValueKeyMap,
                    onClickHandler,
                    componentViewType,
                    Color.parseColor(appCMSPresenter.getAppCMSMain().getBrand().getCta().getPrimary().getTextColor()), appCMSPresenter, position);
        }
        updatePlaylistAllStatus();
    }

    private void updatePlaylistAllStatus() {
        if (appCMSPresenter != null && appCMSPresenter.getCurrentActivity() != null && appCMSPresenter.getCurrentActivity().findViewById(R.id.playlist_download_id) != null && appCMSPresenter.isAllPlaylistAudioDownloaded(moduleAPI.getContentData())) {
            ((ImageButton) appCMSPresenter.getCurrentActivity().findViewById(R.id.playlist_download_id)).setImageResource(R.drawable.ic_downloaded);
            appCMSPresenter.getCurrentActivity().findViewById(R.id.playlist_download_id).setVisibility(View.GONE);
        }
    }


    private void playPlaylistItem(ContentDatum data, View itemView, int clickPosition) {
        if (data.getGist() != null &&
                data.getGist().getMediaType() != null &&
                data.getGist().getMediaType().toLowerCase().contains(itemView.getContext().getString(R.string.media_type_audio).toLowerCase()) &&
                data.getGist().getContentType() != null &&
                data.getGist().getContentType().toLowerCase().contains(itemView.getContext().getString(R.string.content_type_audio).toLowerCase())) {
            appCMSPresenter.getCurrentActivity().sendBroadcast(new Intent(AppCMSPresenter
                    .PRESENTER_PAGE_LOADING_ACTION));
            // on click from playlist adapter .Get playlist from temp list and set into current playlist
            if ((AudioPlaylistHelper.getInstance().getCurrentPlaylistId() == null) || (AudioPlaylistHelper.getInstance().getCurrentPlaylistId() != null && !AudioPlaylistHelper.getInstance().getCurrentPlaylistId().equalsIgnoreCase(mCurrentPlayListId))) {
                AudioPlaylistHelper.getInstance().setCurrentPlaylistId(mCurrentPlayListId);
                AudioPlaylistHelper.getInstance().setCurrentPlaylistData(AudioPlaylistHelper.getInstance().getTempPlaylistData());
                AudioPlaylistHelper.getInstance().setPlaylist(MusicLibrary.createPlaylistByIDList(AudioPlaylistHelper.getInstance().getTempPlaylistData().getAudioList()));
            }
            if (adapterData.size() > oldClick) {
                if (oldClick != clickPosition) {
                    if (oldClick == -1) {
                        oldClick = clickPosition;
                        data.getGist().setAudioPlaying(true);
                    } else {
                        adapterData.get(oldClick).getGist().setAudioPlaying(false);
                        oldClick = clickPosition;
                        data.getGist().setAudioPlaying(true);
                    }
                }
            }
            updateData(mRecyclerView, adapterData);
            AudioPlaylistHelper.getInstance().playAudioOnClickItem(data.getGist().getId(), 0);
            return;
        }
    }

    @Override
    public void onDetachedFromRecyclerView(@NonNull RecyclerView recyclerView) {
        super.onDetachedFromRecyclerView(recyclerView);
        if (mContext != null)
            mContext.unregisterReceiver(serviceReceiver);
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        CollectionGridItemView componentView;

        public ViewHolder(View itemView) {
            super(itemView);
            this.componentView = (CollectionGridItemView) itemView;
        }

    }

    @Override
    public void addReceiver(OnInternalEvent e) {
        receivers.add(e);
    }

    @Override
    public void sendEvent(InternalEvent<?> event) {
        for (OnInternalEvent internalEvent : receivers) {
            internalEvent.receiveEvent(event);
        }
    }

    @Override
    public void receiveEvent(InternalEvent<?> event) {
        adapterData.clear();
        notifyDataSetChanged();
    }

    @Override
    public void cancel(boolean cancel) {

    }

    @Override
    public String getModuleId() {
        return moduleId;
    }

    @Override
    public void setModuleId(String moduleId) {
        this.moduleId = moduleId;
    }


    @Override
    public void setClickable(boolean clickable) {
        isClickable = clickable;
    }

    private String getDownloadAudioAction(Context context) {
        return context.getString(R.string.app_cms_download_audio_action);
    }


    public void startDownloadPlaylist() {
        appCMSPresenter.askForPermissionToDownloadForPlaylist(true, new Action1<Boolean>() {
            @Override
            public void call(Boolean isStartDownload) {
                if (isStartDownload) {
                    getPlaylistAudioItems();
                }
            }
        });
    }

    private  int countDownloadPlaylist= 0;
    private void getPlaylistAudioItems() {
        countDownloadPlaylist= 0;
        //appCMSPresenter.showLoadingDialog(true);

        //progressDialogInit();

        isPlaylistDownloading = true;
        for (int i = 0; i < allViews.length; i++) {
            if (allViews[i] != null && allViews[i].getChildItems() != null) {
                for (int j = 0; j < allViews[i].getChildItems().size(); j++) {
                    CollectionGridItemView.ItemContainer itemContainer = allViews[i].getChildItems().get(j);
                    if (itemContainer.getComponent().getKey() != null) {
                        if (itemContainer.getComponent().getKey().contains(mContext.getString(R.string.app_cms_page_audio_download_button_key))) {

                            ImageButton download = (ImageButton) itemContainer.getChildView();
                            download.setTag(true);
                            isDownloading = true;
//                            DownloadUpdate downloadTag = new DownloadUpdate();
//                            downloadTag.setClick(false);
////                            downloadTag.setDowloading(false);
//                            download.setTag(downloadTag);
                            isDownloading = true;
                            Handler handler = new Handler();
                            final int pos = i;
//
//                            AppCMSPresenter.PlaylistDetails detailsPlay=new AppCMSPresenter.PlaylistDetails();
//                            detailsPlay.setImgButton(download);
//                            detailsPlay.setData(adapterData.get(pos));
//                            appCMSPresenter.playlistDowloadValues.put(adapterData.get(pos).getGist().getId(),detailsPlay);
                            handler.postDelayed(new Runnable() {
                                @Override
                                public void run() {
                                    playlistAudioDownload(download, adapterData.get(pos).getGist().getId(), true);
                                }
                            }, 200);

//                            playlistAudioDownload(download, adapterData.get(pos).getGist().getId(), true);
                        }
                    }
                }


            }
        }
//        Iterator iterator=appCMSPresenter.playlistDowloadValues.entrySet().iterator();
//        while(iterator.hasNext()){
//            Map.Entry<String,AppCMSPresenter.PlaylistDetails> pairs = (Map.Entry<String, AppCMSPresenter.PlaylistDetails>) iterator.next();
//            AppCMSPresenter.PlaylistDetails detailsPlay= pairs.getValue();
////                    String key= String.valueOf(iterator.next());
////                    AppCMSPresenter.PlaylistDetails detailsPlay=appCMSPresenter.playlistDowloadValues.get(key);
//            Handler handler = new Handler();
//
//            handler.postDelayed(new Runnable() {
//                @Override
//                public void run() {
//                    System.out.println("response receive for-"+appCMSAudioDetailResult.getGist().getTitle());
//
//                    updateDownloadImageAndStartDownloadProcess(detailsPlay.getData(), detailsPlay.getImgButton(), true);
//                }
//            }, 500);
//
////            playlistAudioDownload(detailsPlay.getImgButton(),pairs.getKey(),true);
//        }
    }

    void playlistAudioDownload(ImageButton download, String id, boolean playlistDowload) {
        appCMSPresenter.getAudioDetailPlaylist(id,
                0, null, false, false, 0,
                new AppCMSPresenter.AppCMSAudioDetailAPIAction(false,
                        false,
                        false,
                        null,
                        id,
                        id,
                        null,
                        id,
                        false, null) {
                    @Override
                    public void call(AppCMSAudioDetailResult appCMSAudioDetailResult) {
                        AppCMSPageAPI audioApiDetail = appCMSAudioDetailResult.convertToAppCMSPageAPI(id);
                        updateDownloadImageAndStartDownloadProcess(audioApiDetail.getModules().get(0).getContentData().get(0), download, playlistDowload);
                    }
                });

    }

    synchronized void audioDownload(ImageButton download, ContentDatum data, boolean playlistDowload) {
        appCMSPresenter.getAudioDetail(data.getGist().getId(),
                0, null, false, false, 0,
                new AppCMSPresenter.AppCMSAudioDetailAPIAction(false,
                        false,
                        false,
                        null,
                        data.getGist().getId(),
                        data.getGist().getId(),
                        null,
                        data.getGist().getId(),
                        false, null) {
                    @Override
                    public void call(AppCMSAudioDetailResult appCMSAudioDetailResult) {

                        AppCMSPageAPI audioApiDetail = appCMSAudioDetailResult.convertToAppCMSPageAPI(data.getGist().getId());
                        updateDownloadImageAndStartDownloadProcess(audioApiDetail.getModules().get(0).getContentData().get(0), download, playlistDowload);
                    }
                });

    }

    synchronized void updateDownloadImageAndStartDownloadProcess(ContentDatum contentDatum, ImageButton downloadView,
                                                                 Boolean playlistDownload) {
        String userId = appCMSPresenter.getLoggedInUser();
        int radiusDifference = 5;
        if (BaseView.isTablet(mContext)) {
            radiusDifference = 2;
        }

        UpdateDownloadImageIconAction updateDownloadImageIconAction = new UpdateDownloadImageIconAction(downloadView,
                appCMSPresenter,
                contentDatum, userId, playlistDownload, radiusDifference, userId);
        updateDownloadImageIconAction.updateDownloadImageButton((ImageButton) downloadView);

        appCMSPresenter.getUserVideoDownloadStatus(
                contentDatum.getGist().getId(),
                updateDownloadImageIconAction, userId);
    }
//    synchronized void updateDownloadImageAndStartDownloadProcess(ContentDatum contentDatum, ImageButton downloadView) {
//        String userId = appCMSPresenter.getLoggedInUser();
//        Map<String, ViewCreator.UpdateDownloadImageIconAction> updateDownloadImageIconActionMap =
//                appCMSPresenter.getUpdateDownloadImageIconActionMap();
//        try {
//            int radiusDifference = 5;
//            if (BaseView.isTablet(mContext)) {
//                radiusDifference = 2;
//            }
//            ViewCreator.UpdateDownloadImageIconAction updateDownloadImageIconAction =
//                    updateDownloadImageIconActionMap.get(contentDatum.getGist().getId());
//            if (updateDownloadImageIconAction == null) {
//
//                updateDownloadImageIconAction = new ViewCreator.UpdateDownloadImageIconAction(downloadView, appCMSPresenter,
//                        contentDatum, userId, radiusDifference, moduleId);
//                updateDownloadImageIconActionMap.put(contentDatum.getGist().getId(), updateDownloadImageIconAction);
//            }
//
//            downloadView.setTag(contentDatum.getGist().getId());
//
//            updateDownloadImageIconAction.updateDownloadImageButton(downloadView);
//            updateDownloadImageIconAction.updateContentData(contentDatum);
//
//            appCMSPresenter.getUserVideoDownloadStatus(
//                    contentDatum.getGist().getId(), updateDownloadImageIconAction, userId);
//        } catch (Exception e) {
//
//        }
//    }


    private class updateDataReceiver extends BroadcastReceiver {

        @Override
        public void onReceive(Context arg0, Intent arg1) {
            System.out.println("update playlist receiver");
//            notifyDataSetChanged();
            AppCMSPlaylistAdapter.this.notifyDataSetChanged();
        }


    }

    public class DownloadUpdate {
        private boolean isClick;

        public boolean isClick() {
            return isClick;
        }

        public void setClick(boolean click) {
            isClick = click;
        }

        public boolean isDowloading() {
            return isDowloading;
        }

        public void setDowloading(boolean dowloading) {
            isDowloading = dowloading;
        }

        private boolean isDowloading;

    }


    /**
     * This class has been created to updated the Download Image Action and Status
     */
    private class UpdateDownloadImageIconAction implements Action1<UserVideoDownloadStatus> {
        private final AppCMSPresenter appCMSPresenter;
        private final ContentDatum contentDatum;
        private final String userId;
        private ImageButton imageButton;
        private Boolean playlistDownload;
        private View.OnClickListener addClickListener;
        int radiusDifference;
        String id;

        UpdateDownloadImageIconAction(ImageButton imageButton, AppCMSPresenter presenter,
                                      ContentDatum contentDatum, String userId, boolean playlistDownload, int radiusDifference, String id) {
            this.imageButton = imageButton;
            this.appCMSPresenter = presenter;
            this.contentDatum = contentDatum;
            this.playlistDownload = playlistDownload;
            this.userId = userId;
            this.radiusDifference = radiusDifference;
            this.id = id;

            addClickListener = v -> {

                if (!appCMSPresenter.isNetworkConnected()) {
                    if (!appCMSPresenter.isUserLoggedIn()) {
                        appCMSPresenter.showDialog(AppCMSPresenter.DialogType.NETWORK, null, false,
                                appCMSPresenter::launchBlankPage,
                                null);
                        return;
                    }
                    appCMSPresenter.showDialog(AppCMSPresenter.DialogType.NETWORK,
                            appCMSPresenter.getNetworkConnectivityDownloadErrorMsg(),
                            true,
                            () -> appCMSPresenter.navigateToDownloadPage(appCMSPresenter.getDownloadPageId(),
                                    null, null, false),
                            null);
                    return;
                }
                if ((appCMSPresenter.isUserSubscribed()) &&
                        appCMSPresenter.isUserLoggedIn()) {
                    appCMSPresenter.editDownloadFromPlaylist(UpdateDownloadImageIconAction.this.contentDatum, UpdateDownloadImageIconAction.this, true);
                    countDownloadPlaylist++;
                    //progressDialog.setProgress(countDownloadPlaylist);
                    if (countDownloadPlaylist == adapterData.size()){
                        //appCMSPresenter.showLoadingDialog(false);
                        //progressDialog.dismiss();
                    }


                } else {
                    if (appCMSPresenter.isUserLoggedIn()) {
                        appCMSPresenter.showEntitlementDialog(AppCMSPresenter.DialogType.SUBSCRIPTION_REQUIRED_AUDIO,
                                () -> {
                                    appCMSPresenter.setAfterLoginAction(() -> {

                                    });
                                });
                    } else {
                        appCMSPresenter.showEntitlementDialog(AppCMSPresenter.DialogType.LOGIN_AND_SUBSCRIPTION_REQUIRED_AUDIO,
                                () -> {
                                    appCMSPresenter.setAfterLoginAction(() -> {

                                    });
                                });
                    }
                }
                imageButton.setOnClickListener(null);
            };
        }

        @Override
        public void call(UserVideoDownloadStatus userVideoDownloadStatus) {
            if (userVideoDownloadStatus != null) {

                switch (userVideoDownloadStatus.getDownloadStatus()) {
                    case STATUS_FAILED:
                        appCMSPresenter.setDownloadInProgress(false);
                        appCMSPresenter.startNextDownload();
                        break;

                    case STATUS_PAUSED:
                        imageButton.setImageResource(R.drawable.ic_download_queued);
                        // Uncomment to allow for Pause/Resume functionality
//                        imageButton.setOnClickListener(addClickListener);
                        imageButton.setOnClickListener(null);
                        break;

                    case STATUS_PENDING:
                        appCMSPresenter.setDownloadInProgress(false);
                        imageButton.setImageResource(R.drawable.ic_download_queued);
                        appCMSPresenter.updateDownloadingStatus(contentDatum.getGist().getId(),
                                UpdateDownloadImageIconAction.this.imageButton, appCMSPresenter, this, userId, false,
                                radiusDifference,
                                id);
                        imageButton.setOnClickListener(null);
                        break;

                    case STATUS_RUNNING:
                        appCMSPresenter.setDownloadInProgress(true);
                        imageButton.setImageResource(0);
                        appCMSPresenter.updateDownloadingStatus(contentDatum.getGist().getId(),
                                UpdateDownloadImageIconAction.this.imageButton, appCMSPresenter, this, userId, false,
                                radiusDifference,
                                id);
                        // Uncomment to allow for Pause/Resume functionality
//                        imageButton.setOnClickListener(addClickListener);
                        imageButton.setOnClickListener(null);
                        break;

                    case STATUS_SUCCESSFUL:
                        imageButton.setImageResource(R.drawable.ic_downloaded_big);
                        imageButton.setScaleType(ImageView.ScaleType.FIT_CENTER);
                        imageButton.setOnClickListener(null);
                        if (appCMSPresenter.downloadTaskRunning(contentDatum.getGist().getId())) {
                            appCMSPresenter.setDownloadInProgress(false);
                            appCMSPresenter.cancelDownloadIconTimerTask(contentDatum.getGist().getId());
                            appCMSPresenter.notifyDownloadHasCompleted();
                        }
//                        appCMSPresenter.playlistDowloadValues.remove(contentDatum.getGist().getId());
//                        if(appCMSPresenter.playlistDowloadValues.size()>0) {
//                            Iterator iterator=appCMSPresenter.playlistDowloadValues.entrySet().iterator();
//                            if(iterator.hasNext()){
//                                Map.Entry<String,AppCMSPresenter.PlaylistDetails> pairs = (Map.Entry<String, AppCMSPresenter.PlaylistDetails>) iterator.next();
//                                AppCMSPresenter.PlaylistDetails detailsPlay= pairs.getValue();
////                    String key= String.valueOf(iterator.next());
////                    AppCMSPresenter.PlaylistDetails detailsPlay=appCMSPresenter.playlistDowloadValues.get(key);
//                                updateDownloadImageAndStartDownloadProcess(detailsPlay.getData(), detailsPlay.getImgButton(), true);
//
////                                playlistAudioDownload(detailsPlay.getImgButton(),pairs.getKey(),true);
//                            }
//                        }
                        break;

                    case STATUS_INTERRUPTED:
                        appCMSPresenter.setDownloadInProgress(false);
                        imageButton.setImageResource(android.R.drawable.stat_sys_warning);
                        imageButton.setScaleType(ImageView.ScaleType.FIT_CENTER);
                        imageButton.setOnClickListener(null);
                        break;

                    default:
                        //Log.d(TAG, "No download Status available ");
                        break;
                }

            } else {
                appCMSPresenter.updateDownloadingStatus(contentDatum.getGist().getId(),
                        UpdateDownloadImageIconAction.this.imageButton, appCMSPresenter, this, userId, false, radiusDifference, id);
                imageButton.setImageResource(R.drawable.ic_download);
                imageButton.setScaleType(ImageView.ScaleType.CENTER_INSIDE);
                int fillColor = Color.parseColor(appCMSPresenter.getAppCMSMain().getBrand().getGeneral().getTextColor());
                imageButton.getDrawable().setColorFilter(new PorterDuffColorFilter(fillColor, PorterDuff.Mode.MULTIPLY));
//                if(isPlaylistDownloading){
//                    imageButton.setOnClickListener(addClickListener);
//                }
//                if ((boolean) imageButton.getTag()) {
////                    imageButton.setTag(false);
//                    System.out.println("download status start");
//
//                    addClickListener.onClick(imageButton);
//                }
//                imageButton.setOnClickListener(addClickListener);
//                addClickListener.onClick(imageButton);

                addClickListener.onClick(imageButton);

//                if ((boolean) imageButton.getTag()) {
//                    imageButton.setTag(false);
//                    addClickListener.onClick(imageButton);
//                }
//                new android.os.Handler().postDelayed(new Runnable() {
//                    @Override
//                    public void run() {
//                        if ((boolean) imageButton.getTag()) {
//                            imageButton.setTag(false);
//
//                            addClickListener.onClick(imageButton);
//                        }
//                    }
//                }, 50);


            }
        }

        public void updateDownloadImageButton(ImageButton imageButton) {
            this.imageButton = imageButton;
        }

    }

}

