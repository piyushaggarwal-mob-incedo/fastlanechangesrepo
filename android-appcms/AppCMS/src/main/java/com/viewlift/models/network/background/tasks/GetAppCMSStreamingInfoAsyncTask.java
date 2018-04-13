package com.viewlift.models.network.background.tasks;

import android.util.Log;

import com.viewlift.models.data.appcms.api.AppCMSStreamingInfo;
import com.viewlift.models.network.rest.AppCMSStreamingInfoCall;

import rx.Observable;
import rx.android.schedulers.AndroidSchedulers;
import rx.functions.Action1;
import rx.schedulers.Schedulers;

/**
 * Created by viewlift on 6/26/17.
 */

public class GetAppCMSStreamingInfoAsyncTask {
    private static final String TAG = "StreamingInfoTask";

    private final AppCMSStreamingInfoCall call;
    private final Action1<AppCMSStreamingInfo> readyAction;

    public static class Params {
        String url;
        boolean loadFromFile;
        public static class Builder {
            private Params params;
            public Builder() {
                this.params = new Params();
            }
            public Builder url(String url) {
                params.url = url;
                return this;
            }
            public Builder loadFromFile(boolean loadFromFile) {
                params.loadFromFile = loadFromFile;
                return this;
            }
            public Params build() {
                return params;
            }
        }
    }

    public GetAppCMSStreamingInfoAsyncTask(AppCMSStreamingInfoCall call,
                                           Action1<AppCMSStreamingInfo> readyAction) {
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
