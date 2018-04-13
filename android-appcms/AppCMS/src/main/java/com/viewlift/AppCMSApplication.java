package com.viewlift;

import android.app.Activity;
import android.os.Bundle;
import android.support.multidex.MultiDexApplication;

import com.appsflyer.AppsFlyerConversionListener;
import com.appsflyer.AppsFlyerLib;
import com.viewlift.models.data.appcms.downloads.DownloadMediaMigration;
import com.viewlift.models.network.modules.AppCMSSiteModule;
import com.viewlift.models.network.modules.AppCMSUIModule;
import com.viewlift.views.components.AppCMSPresenterComponent;
import com.viewlift.views.components.DaggerAppCMSPresenterComponent;
import com.viewlift.views.modules.AppCMSPresenterModule;

import java.util.Map;

import io.realm.Realm;
import io.realm.RealmConfiguration;
import rx.functions.Action0;

import static com.viewlift.analytics.AppsFlyerUtils.trackInstallationEvent;

/*
 * Created by viewlift on 5/4/17.
 */

public class AppCMSApplication extends MultiDexApplication {
    private static String TAG = "AppCMSApp";

    private AppCMSPresenterComponent appCMSPresenterComponent;

    private AppsFlyerConversionListener conversionDataListener;

    private int openActivities;

    private Action0 onActivityResumedAction;

    private void initRealmonfig(){

        Realm.init(this);
        RealmConfiguration config = new RealmConfiguration
                .Builder()
                .schemaVersion(1)
                .migration(new DownloadMediaMigration())
//                .deleteRealmIfMigrationNeeded()
                .build();
        Realm.setDefaultConfiguration(config);
    }

    @Override
    public void onCreate() {
        super.onCreate();

        initRealmonfig();
        openActivities = 0;

        new Thread(() -> {
            conversionDataListener = new AppsFlyerConversionListener() {

                @Override
                public void onInstallConversionDataLoaded(Map<String, String> map) {
                    //
                }

                @Override
                public void onInstallConversionFailure(String s) {
                    //
                }

                @Override
                public void onAppOpenAttribution(Map<String, String> map) {
                    //
                }

                @Override
                public void onAttributionFailure(String s) {
                    //
                }
            };

            appCMSPresenterComponent = DaggerAppCMSPresenterComponent
                    .builder()
                    .appCMSUIModule(new AppCMSUIModule(this))
                    .appCMSSiteModule(new AppCMSSiteModule())
                    .appCMSPresenterModule(new AppCMSPresenterModule())
                    .build();

            appCMSPresenterComponent.appCMSPresenter().setCurrentContext(this);

            registerActivityLifecycleCallbacks(new ActivityLifecycleCallbacks() {
                @Override
                public void onActivityCreated(Activity activity, Bundle savedInstanceState) {
                    appCMSPresenterComponent.appCMSPresenter().setCurrentActivity(activity);
                }

                @Override
                public void onActivityStarted(Activity activity) {
                    //Log.d(TAG, "Activity being started: " + activity.getLocalClassName());
                    openActivities++;
                }

                @Override
                public void onActivityResumed(Activity activity) {
                        appCMSPresenterComponent.appCMSPresenter().setCurrentActivity(activity);
                        if (onActivityResumedAction != null) {
                            onActivityResumedAction.call();
                            onActivityResumedAction = null;
                        }
                }

                @Override
                public void onActivityPaused(Activity activity) {
                    //Log.d(TAG, "Activity being paused: " + activity.getLocalClassName());
                    appCMSPresenterComponent.appCMSPresenter().closeSoftKeyboard();
                }

                @Override
                public void onActivityStopped(Activity activity) {
                    //Log.d(TAG, "Activity being stopped: " + activity.getLocalClassName());
                    if (openActivities == 1) {
                        appCMSPresenterComponent.appCMSPresenter().setCancelAllLoads(true);
                    }

                    openActivities--;
                }

                @Override
                public void onActivitySaveInstanceState(Activity activity, Bundle outState) {

                }

                @Override
                public void onActivityDestroyed(Activity activity) {
                    //Log.d(TAG, "Activity being destroyed: " + activity.getLocalClassName());
                    appCMSPresenterComponent.appCMSPresenter().unsetCurrentActivity(activity);
                    appCMSPresenterComponent.appCMSPresenter().closeSoftKeyboard();
                }
            });

        }).run();
    }

    public AppCMSPresenterComponent getAppCMSPresenterComponent() {
        return appCMSPresenterComponent;
    }

    public void initAppsFlyer(String appsFlyerKey) {
        AppsFlyerLib.getInstance().init(appsFlyerKey, conversionDataListener);
        sendAnalytics();
    }

    private void sendAnalytics() {
        trackInstallationEvent(this);
    }

    public Action0 getOnActivityResumedAction() {
        return onActivityResumedAction;
    }

    public void setOnActivityResumedAction(Action0 onActivityResumedAction) {
        this.onActivityResumedAction = onActivityResumedAction;
    }


}
