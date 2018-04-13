package com.viewlift.models.network.rest;

/*
 * Created by Viewlift on 6/28/2017.
 */

import android.support.annotation.NonNull;
import android.support.annotation.WorkerThread;
import android.util.Log;

import com.google.gson.Gson;
import com.viewlift.models.data.appcms.audio.AppCMSAudioDetailResult;
import com.viewlift.models.data.appcms.playlist.AppCMSPlaylistResult;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import javax.inject.Inject;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import rx.Observable;
import rx.Subscriber;
import rx.android.schedulers.AndroidSchedulers;
import rx.functions.Action1;
import rx.schedulers.Schedulers;

public class AppCMSAudioDetailCall {

    private static final String TAG = AppCMSAudioDetailCall.class.getSimpleName() + "TAG";
    private final AppCMSAudioDetailRest appCMSAudioDetailRest;

    @SuppressWarnings({"unused, FieldCanBeLocal"})
    private final Gson gson;

    @Inject
    public AppCMSAudioDetailCall(AppCMSAudioDetailRest appCMSAudioDetailRest, Gson gson) {
        this.appCMSAudioDetailRest = appCMSAudioDetailRest;
        this.gson = gson;
    }

    public void call(String url, final Action1<AppCMSAudioDetailResult> audioDetailResultAction) throws IOException {
        try {
            appCMSAudioDetailRest.get(url).enqueue(new Callback<AppCMSAudioDetailResult>() {
                @Override
                public void onResponse(@NonNull Call<AppCMSAudioDetailResult> call,
                                       @NonNull Response<AppCMSAudioDetailResult> response) {
                    Observable.just(response.body()).subscribe(audioDetailResultAction);


                }

                @Override
                public void onFailure(@NonNull Call<AppCMSAudioDetailResult> call,
                                      @NonNull Throwable t) {
                    //Log.e(TAG, "onFailure: " + t.getMessage());
                    audioDetailResultAction.call(null);
                }
            });
        } catch (Exception e) {
            //Log.e(TAG, "Failed to execute watchlist " + url + ": " + e.toString());
        }
    }

    public void call(String url, final Action1<AppCMSAudioDetailResult> audioDetailResultAction, boolean isFalse) throws IOException {
        try {
            appCMSAudioDetailRest.getPlayList("","").subscribeOn(Schedulers.io()).observeOn(AndroidSchedulers.mainThread()).subscribe(new Subscriber<AppCMSAudioDetailResult>() {
                @Override
                public void onCompleted() {
                    Log.d("TAG", "Complete");
                }

                @Override
                public void onError(Throwable e) {
                    audioDetailResultAction.call(null);
                }

                @Override
                public void onNext(AppCMSAudioDetailResult appCMSAudioDetailResult) {
                    Observable.just(appCMSAudioDetailResult).subscribe(audioDetailResultAction);
                }
            });
        } catch (Exception e) {
            Log.e(TAG, "Failed to execute watchlist " + url + ": " + e.toString());
        }
    }
}
