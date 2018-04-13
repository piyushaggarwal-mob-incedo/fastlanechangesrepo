package com.viewlift.models.network.background.tasks;

import android.util.Log;

import com.viewlift.models.data.appcms.ui.authentication.RefreshIdentityResponse;
import com.viewlift.models.network.rest.AppCMSRefreshIdentityCall;

import rx.Observable;
import rx.android.schedulers.AndroidSchedulers;
import rx.functions.Action1;
import rx.schedulers.Schedulers;

/**
 * Created by viewlift on 7/5/17.
 */

public class GetAppCMSRefreshIdentityAsyncTask {
    private final AppCMSRefreshIdentityCall call;
    private final Action1<RefreshIdentityResponse> readyAction;

    private static final String TAG = "RefreshIdentityTask";

    public static class Params {
        String url;
        public static class Builder {
            private Params params;
            public Builder() {
                this.params = new Params();
            }
            public Builder url(String url) {
                params.url = url;
                return this;
            }
            public Params build() {
                return params;
            }
        }
    }

    public GetAppCMSRefreshIdentityAsyncTask(AppCMSRefreshIdentityCall call,
                                             Action1<RefreshIdentityResponse> readyAction) {
        this.call = call;
        this.readyAction = readyAction;
    }

    public void execute(Params params) {
        Observable
                .fromCallable(() -> {
                    if (params != null) {
                        try {
                            return call.call(params.url);
                        } catch (Exception e) {
                            //Log.e(TAG, "DialogType retrieving page API data: " + e.getMessage());
                        }
                    }
                    return null;
                })
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .onErrorResumeNext(throwable -> Observable.empty())
                .subscribe((result) -> Observable.just(result).subscribe(readyAction));
    }
}
