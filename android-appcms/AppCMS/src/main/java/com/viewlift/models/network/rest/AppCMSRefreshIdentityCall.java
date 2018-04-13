package com.viewlift.models.network.rest;

import android.util.Log;

import com.google.gson.JsonSyntaxException;
import com.viewlift.models.data.appcms.ui.authentication.RefreshIdentityResponse;

import java.io.IOException;

import javax.inject.Inject;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import rx.Observable;
import rx.functions.Action1;

/**
 * Created by viewlift on 7/5/17.
 */

public class AppCMSRefreshIdentityCall {
    private static final String TAG = "AppCMSRefreshIdentity";

    private final AppCMSRefreshIdentityRest appCMSRefreshIdentityRest;

    @Inject
    public AppCMSRefreshIdentityCall(AppCMSRefreshIdentityRest appCMSRefreshIdentityRest) {
        this.appCMSRefreshIdentityRest = appCMSRefreshIdentityRest;
    }

    public RefreshIdentityResponse call(String url) {
        try {
            return appCMSRefreshIdentityRest.get(url).execute().body();
        } catch (JsonSyntaxException e) {
            //Log.e(TAG, "JsonSyntaxException retrieving Refresh Identity Response: " + e.toString());
        } catch (IOException e) {
            //Log.e(TAG, "IO error retrieving Refresh Identity Response: " + e.toString());
        }
        return null;
    }

    public void call(String url, final Action1<RefreshIdentityResponse> readyAction) {
        appCMSRefreshIdentityRest.get(url).enqueue(new Callback<RefreshIdentityResponse>() {
            @Override
            public void onResponse(Call<RefreshIdentityResponse> call, Response<RefreshIdentityResponse> response) {
                Observable.just(response.body())
                        .onErrorResumeNext(throwable -> Observable.empty())
                        .subscribe(readyAction);
            }

            @Override
            public void onFailure(Call<RefreshIdentityResponse> call, Throwable t) {
                //Log.e(TAG, "DialogType retrieving Refresh Identity Response");
                Observable.just((RefreshIdentityResponse) null)
                        .onErrorResumeNext(throwable -> Observable.empty())
                        .subscribe(readyAction);
            }
        });
    }
}
