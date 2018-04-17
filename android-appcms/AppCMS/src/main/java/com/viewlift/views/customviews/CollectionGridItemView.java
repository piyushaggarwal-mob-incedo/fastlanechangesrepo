package com.viewlift.views.customviews;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.LinearGradient;
import android.graphics.Paint;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffXfermode;
import android.graphics.Shader;
import android.graphics.drawable.GradientDrawable;
import android.support.annotation.NonNull;
import android.support.v4.content.ContextCompat;
import android.support.v7.widget.CardView;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.style.StrikethroughSpan;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.Transformation;
import com.bumptech.glide.load.engine.DiskCacheStrategy;
import com.bumptech.glide.load.engine.bitmap_recycle.BitmapPool;
import com.bumptech.glide.load.resource.bitmap.BitmapTransformation;
import com.bumptech.glide.request.RequestOptions;
import com.viewlift.R;
import com.viewlift.models.data.appcms.api.ContentDatum;
import com.viewlift.models.data.appcms.downloads.DownloadStatus;
import com.viewlift.models.data.appcms.ui.AppCMSUIKeyType;
import com.viewlift.models.data.appcms.ui.page.Component;
import com.viewlift.models.data.appcms.ui.page.Layout;
import com.viewlift.presenters.AppCMSPresenter;
import com.viewlift.views.utilities.ImageLoader;
import com.viewlift.views.utilities.ImageUtils;

import net.nightwhistler.htmlspanner.TextUtil;

import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Currency;
import java.util.List;
import java.util.Map;

import javax.inject.Inject;

/*
 * Created by viewlift on 5/5/17.
 */

@SuppressLint("ViewConstructor")
public class CollectionGridItemView extends BaseView {
    private static final String TAG = "CollectionItemView";

    private final Layout parentLayout;
    private final boolean useParentLayout;
    private final Component component;
    private final String moduleId;
    protected int defaultWidth;
    protected int defaultHeight;
    AppCMSUIKeyType viewTypeKey;
    private List<ItemContainer> childItems;
    private List<View> viewsToUpdateOnClickEvent;
    private boolean selectable;
    private boolean createMultipleContainersForChildren;
    private boolean createRoundedCorners;

    @Inject
    public CollectionGridItemView(Context context,
                                  Layout parentLayout,
                                  boolean useParentLayout,
                                  Component component,
                                  String moduleId,
                                  int defaultWidth,
                                  int defaultHeight,
                                  boolean createMultipleContainersForChildren,
                                  boolean createRoundedCorners,
                                  AppCMSUIKeyType viewTypeKey) {
        super(context);
        this.parentLayout = parentLayout;
        this.useParentLayout = useParentLayout;
        this.component = component;
        this.moduleId = moduleId;
        this.defaultWidth = defaultWidth;
        this.defaultHeight = defaultHeight;
        this.viewsToUpdateOnClickEvent = new ArrayList<>();
        this.createMultipleContainersForChildren = createMultipleContainersForChildren;
        this.createRoundedCorners = createRoundedCorners;
        this.viewTypeKey = viewTypeKey;
        init();
    }

    @Override
    public void init() {
        int width = (int) getGridWidth(getContext(),
                component.getLayout(),
                (int) getViewWidth(getContext(),
                        component.getLayout(),
                        defaultWidth));
        int height = (int) getGridHeight(getContext(),
                component.getLayout(),
                (int) getViewHeight(getContext(),
                        component.getLayout(),
                        defaultHeight));

        FrameLayout.LayoutParams layoutParams;
        int paddingHorizontal = 0;
        if (component.getStyles() != null) {
            paddingHorizontal = (int) convertHorizontalValue(getContext(), component.getStyles().getPadding());
        } else if (getTrayPadding(getContext(), component.getLayout()) != -1.0f) {
            int trayPadding = (int) getTrayPadding(getContext(), component.getLayout());
            paddingHorizontal = (int) convertHorizontalValue(getContext(), trayPadding);
        }
        int horizontalMargin = paddingHorizontal;
        int verticalMargin = 0;
        MarginLayoutParams marginLayoutParams = new MarginLayoutParams(width, height);
        marginLayoutParams.setMargins(horizontalMargin,
                verticalMargin,
                horizontalMargin,
                verticalMargin);
        layoutParams = new FrameLayout.LayoutParams(marginLayoutParams);
        setLayoutParams(layoutParams);
        childItems = new ArrayList<>();
        if (component.getComponents() != null) {
            initializeComponentHasViewList(component.getComponents().size());
        }
    }

    @Override
    protected Component getChildComponent(int index) {
        if (component.getComponents() != null &&
                0 <= index &&
                index < component.getComponents().size()) {
            return component.getComponents().get(index);
        }
        return null;
    }

    @Override
    protected Layout getLayout() {
        return component.getLayout();
    }

    @Override
    protected ViewGroup createChildrenContainer() {
        if (createMultipleContainersForChildren && BaseView.isTablet(getContext()) && BaseView.isLandscape(getContext())) {
            if (component != null &&
                    component.getView() != null &&
                    component.getView().equalsIgnoreCase(getContext().getResources().getString(R.string.app_cms_page_event_carousel_module_key))) {
                childrenContainer = new CardView(getContext());
                CardView.LayoutParams childContainerLayoutParams =
                        new CardView.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
                                ViewGroup.LayoutParams.MATCH_PARENT);
                childrenContainer.setLayoutParams(childContainerLayoutParams);

                if (createRoundedCorners) {
                    ((CardView) childrenContainer).setRadius(14);
                    setBackgroundResource(android.R.color.transparent);
                    if (!component.getAction().equalsIgnoreCase("purchasePlan")) {
                        childrenContainer.setBackgroundResource(android.R.color.transparent);
                    }
                } else {
                    childrenContainer.setBackgroundResource(android.R.color.transparent);
                }
            } else {
                childrenContainer = new LinearLayout(getContext());
                ((LinearLayout) childrenContainer).setOrientation(LinearLayout.HORIZONTAL);
                LinearLayout.LayoutParams childContainerLayoutParams =
                        new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
                                ViewGroup.LayoutParams.MATCH_PARENT);
                childrenContainer.setLayoutParams(childContainerLayoutParams);
                CardView imageChildView = new CardView(getContext());
                LinearLayout.LayoutParams imageChildViewLayoutParams =
                        new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.MATCH_PARENT);
                imageChildViewLayoutParams.weight = 2;
                imageChildView.setLayoutParams(imageChildViewLayoutParams);
                imageChildView.setBackgroundColor(ContextCompat.getColor(getContext(), android.R.color.transparent));
                childrenContainer.addView(imageChildView);
                CardView detailsChildView = new CardView(getContext());
                LinearLayout.LayoutParams detailsChildViewLayoutParams =
                        new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT);
                detailsChildViewLayoutParams.weight = 1;
                detailsChildView.setLayoutParams(detailsChildViewLayoutParams);
                detailsChildView.setBackgroundColor(ContextCompat.getColor(getContext(), android.R.color.transparent));
                childrenContainer.addView(detailsChildView);
            }
        } else {
            childrenContainer = new CardView(getContext());
            CardView.LayoutParams childContainerLayoutParams =
                    new CardView.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
                            ViewGroup.LayoutParams.MATCH_PARENT);
            childrenContainer.setLayoutParams(childContainerLayoutParams);

            if (createRoundedCorners) {
                ((CardView) childrenContainer).setRadius(14);
                setBackgroundResource(android.R.color.transparent);
                if (!component.getAction().equalsIgnoreCase("purchasePlan")) {
                    childrenContainer.setBackgroundResource(android.R.color.transparent);
                }
            } else {
                childrenContainer.setBackgroundResource(android.R.color.transparent);
            }
        }
        addView(childrenContainer);
        return childrenContainer;
    }

    @Override
    public boolean performClick() {
        return super.performClick();
    }

    public void addChild(ItemContainer itemContainer) {
        if (childrenContainer == null) {
            createChildrenContainer();
        }
        childItems.add(itemContainer);

        if (createMultipleContainersForChildren && BaseView.isTablet(getContext()) && BaseView.isLandscape(getContext())) {
            if (component != null &&
                    component.getView() != null &&
                    component.getView().equalsIgnoreCase(getContext().getResources().getString(R.string.app_cms_page_event_carousel_module_key))) {
                childrenContainer.addView(itemContainer.childView);
            } else if (getContext().getString(R.string.app_cms_page_carousel_image_key).equalsIgnoreCase(itemContainer.component.getKey())) {
                ((ViewGroup) childrenContainer.getChildAt(0)).addView(itemContainer.childView);
            } else {
                ((ViewGroup) childrenContainer.getChildAt(1)).addView(itemContainer.childView);
            }
        } else {
            childrenContainer.addView(itemContainer.childView);
        }
    }

    public View getChild(int index) {
        if (0 <= index && index < childItems.size()) {
            return childItems.get(index).childView;
        }
        return null;
    }

    public int getNumberOfChildren() {
        return childItems.size();
    }

    public boolean isSelectable() {
        return selectable;
    }

    public void setSelectable(boolean selectable) {
        this.selectable = selectable;
    }

    public void bindChild(Context context,
                          View view,
                          final ContentDatum data,
                          Map<String, AppCMSUIKeyType> jsonValueKeyMap,
                          final OnClickHandler onClickHandler,
                          final String componentViewType,
                          int themeColor,
                          AppCMSPresenter appCMSPresenter, int position) {

        final Component childComponent = matchComponentToView(view);

        AppCMSUIKeyType moduleType = jsonValueKeyMap.get(componentViewType);

        if (moduleType == null) {
            moduleType = AppCMSUIKeyType.PAGE_EMPTY_KEY;
        }

        Map<String, ViewCreator.UpdateDownloadImageIconAction> updateDownloadImageIconActionMap =
                appCMSPresenter.getUpdateDownloadImageIconActionMap();

        if (childComponent != null) {
            view.setOnClickListener(v -> onClickHandler.click(CollectionGridItemView.this,
                    childComponent, data, position));
            boolean bringToFront = true;
            AppCMSUIKeyType appCMSUIcomponentViewType = jsonValueKeyMap.get(componentViewType);
            AppCMSUIKeyType componentType = jsonValueKeyMap.get(childComponent.getType());
            AppCMSUIKeyType componentKey = jsonValueKeyMap.get(childComponent.getKey());
            if (componentType == AppCMSUIKeyType.PAGE_IMAGE_KEY) {
                if (componentKey == AppCMSUIKeyType.PAGE_THUMBNAIL_IMAGE_KEY ||
                        componentKey == AppCMSUIKeyType.PAGE_CAROUSEL_IMAGE_KEY ||
                        componentKey == AppCMSUIKeyType.PAGE_VIDEO_IMAGE_KEY ||
                        componentKey == AppCMSUIKeyType.PAGE_BADGE_IMAGE_KEY ||
                        componentKey == AppCMSUIKeyType.PAGE_PLAY_IMAGE_KEY ||
                        componentKey == AppCMSUIKeyType.PAGE_THUMBNAIL_BADGE_IMAGE ||
                        componentKey == AppCMSUIKeyType.PAGE_PHOTO_GALLERY_IMAGE_KEY) {
                    int placeholder = R.drawable.vid_image_placeholder_land;
                    int childViewWidth = (int) getViewWidth(getContext(),
                            childComponent.getLayout(),
                            ViewGroup.LayoutParams.MATCH_PARENT);
                    int childViewHeight = (int) getViewHeight(getContext(),
                            childComponent.getLayout(),
                            getViewHeight(getContext(), component.getLayout(), ViewGroup.LayoutParams.WRAP_CONTENT));

                    if (useParentLayout) {
                        childViewWidth = (int) getGridWidth(getContext(),
                                parentLayout,
                                (int) getViewWidth(getContext(),
                                        parentLayout,
                                        defaultWidth));
                        childViewHeight = (int) getGridHeight(getContext(),
                                parentLayout,
                                (int) getViewHeight(getContext(),
                                        parentLayout,
                                        defaultHeight));
                    }

                    if (childViewWidth < 0 &&
                            componentKey == AppCMSUIKeyType.PAGE_CAROUSEL_IMAGE_KEY) {
                        childViewWidth = (16 * childViewHeight) / 9;
                    }
                    if (0 < childViewWidth && 0 < childViewHeight) {
                        if (childViewWidth < childViewHeight) {
                            childViewHeight = (int) ((float) childViewWidth * 4.0f / 3.0f);
                        } else {
                            childViewHeight = (int) ((float) childViewWidth * 9.0f / 16.0f);
                        }
                    }

                    if (componentKey == AppCMSUIKeyType.PAGE_THUMBNAIL_IMAGE_KEY ||
                            componentKey == AppCMSUIKeyType.PAGE_CAROUSEL_IMAGE_KEY ||
                            componentKey == AppCMSUIKeyType.PAGE_VIDEO_IMAGE_KEY) {
                        if (childViewHeight > childViewWidth) {
                            placeholder = R.drawable.vid_image_placeholder_port;
                            ((ImageView) view).setScaleType(ImageView.ScaleType.FIT_XY);
                            ((ImageView) view).setImageResource(R.drawable.vid_image_placeholder_port);

                        } else {
                            placeholder = R.drawable.vid_image_placeholder_land;

                            ((ImageView) view).setScaleType(ImageView.ScaleType.FIT_XY);
                            ((ImageView) view).setImageResource(R.drawable.vid_image_placeholder_land);
                        }
                    }
                    if (data.getGist() != null &&
                            data.getGist().getContentType() != null &&
                            data.getGist().getContentType().equalsIgnoreCase(context.getString(R.string.content_type_audio))
                            && appCMSUIcomponentViewType == AppCMSUIKeyType.PAGE_PLAYLIST_MODULE_KEY) {
                        int size = childViewWidth;
                        if (childViewWidth < childViewHeight) {
                            size = childViewHeight;
                        }
                        int horizontalMargin = 0;
                        horizontalMargin = (int) getHorizontalMargin(getContext(), childComponent.getLayout());
                        int verticalMargin = (int) getVerticalMargin(getContext(), parentLayout, size, 0);
                        if (verticalMargin < 0) {
                            verticalMargin = (int) convertVerticalValue(getContext(), getYAxis(getContext(), getLayout(), 0));
                        }
                        ((ImageView) view).setScaleType(ImageView.ScaleType.FIT_XY);
                        LayoutParams llParams = new LayoutParams(size, size);
                        llParams.setMargins(horizontalMargin,
                                verticalMargin,
                                horizontalMargin,
                                verticalMargin);
                        view.setLayoutParams(llParams);
                        if (data.getGist() != null &&
                                data.getGist().getImageGist() != null &&
                                data.getGist().getImageGist().get_1x1() != null && (componentKey == AppCMSUIKeyType.PAGE_THUMBNAIL_IMAGE_KEY)) {
                            String imageUrl = data.getGist().getImageGist().get_1x1();
                            if (appCMSPresenter.isVideoDownloaded(data.getGist().getId())) {
                                if (data.getGist().getVideoImageUrl() != null) {
                                    imageUrl = data.getGist().getVideoImageUrl();
                                }
                            }
                            RequestOptions requestOptions = new RequestOptions()
                                    .override(childViewWidth, childViewHeight).placeholder(placeholder)
                                    .fitCenter();
//                            RequestOptions requestOptions = new RequestOptions().placeholder(placeholder);
                            if (!ImageUtils.loadImage((ImageView) view, imageUrl, ImageLoader.ScaleType.START) && context != null && appCMSPresenter != null && appCMSPresenter.getCurrentActivity() != null && !appCMSPresenter.getCurrentActivity().isFinishing()) {


                                Glide.with(context.getApplicationContext())
                                        .load(imageUrl)
                                        .apply(requestOptions)
//                                        .override(size,size)
                                        .into(((ImageView) view));
                            }
                        } else {
                            ((ImageView) view).setScaleType(ImageView.ScaleType.FIT_XY);
                            ((ImageView) view).setImageResource(R.drawable.vid_image_placeholder_square);
                        }
                    } else if (childViewHeight > childViewWidth &&
                            childViewHeight > 0 &&
                            childViewWidth > 0 &&
                            !TextUtils.isEmpty(data.getGist().getPosterImageUrl()) &&
                            (componentKey == AppCMSUIKeyType.PAGE_THUMBNAIL_IMAGE_KEY ||
                                    componentKey == AppCMSUIKeyType.PAGE_VIDEO_IMAGE_KEY)) {
                        bringToFront = false;
                        ((ImageView) view).setScaleType(ImageView.ScaleType.FIT_CENTER);

                        String imageUrl = context.getString(R.string.app_cms_image_with_resize_query,
                                data.getGist().getPosterImageUrl(),
                                childViewWidth,
                                childViewHeight);

                        if (appCMSPresenter.isVideoDownloaded(data.getGist().getId())) {
                            if (data.getGist().getVideoImageUrl() != null) {
                                imageUrl = data.getGist().getVideoImageUrl();
                            }
                        }
                        //Log.d(TAG, "Loading image: " + imageUrl);
                        try {
                            if (!ImageUtils.loadImage((ImageView) view, imageUrl, ImageLoader.ScaleType.START)) {
                                RequestOptions requestOptions = new RequestOptions()
                                        .override(childViewWidth, childViewHeight).placeholder(placeholder)
                                        .fitCenter();
//                                        .override(Target.SIZE_ORIGINAL, Target.SIZE_ORIGINAL);
                                Glide.with(context)
                                        .load(imageUrl)
                                        .apply(requestOptions)
                                        .into((ImageView) view);
                            } else {
                                ((ImageView) view).setBackgroundResource(R.drawable.img_placeholder);
                            }
                        } catch (Exception e) {
                            //
                        }
                    } else if (childViewHeight > 0 &&
                            childViewWidth > 0 &&
                            data != null &&
                            data.getGist() != null &&
                            ((data.getGist().getVideoImageUrl() != null &&
                                    !TextUtils.isEmpty(data.getGist().getVideoImageUrl())) ||
                                    (data.getGist().getImageGist() != null &&
                                            data.getGist().getImageGist().get_16x9() != null &&
                                            !TextUtils.isEmpty(data.getGist().getImageGist().get_16x9()))) &&
                            (componentKey == AppCMSUIKeyType.PAGE_THUMBNAIL_IMAGE_KEY ||
                                    componentKey == AppCMSUIKeyType.PAGE_VIDEO_IMAGE_KEY)) {

                        ((ImageView) view).setScaleType(ImageView.ScaleType.FIT_CENTER);
                        bringToFront = false;
                        String imageUrl = null;
                        if (data.getGist().getVideoImageUrl() != null) {
                            imageUrl = context.getString(R.string.app_cms_image_with_resize_query,
                                    data.getGist().getVideoImageUrl(),
                                    childViewWidth,
                                    childViewHeight);
                            if (appCMSPresenter.isVideoDownloaded(data.getGist().getId())) {
                                if (data.getGist().getVideoImageUrl() != null) {
                                    imageUrl = data.getGist().getVideoImageUrl().equalsIgnoreCase("file:///") ? data.getGist().getPosterImageUrl() : data.getGist().getVideoImageUrl();
                                }
                            }
                        } else {
                            imageUrl = context.getString(R.string.app_cms_image_with_resize_query,
                                    data.getGist().getImageGist().get_16x9(),
                                    childViewWidth,
                                    childViewHeight);
                        }
                        //Log.d(TAG, "Loading image: " + imageUrl);
                        try {
                            if (!ImageUtils.loadImage((ImageView) view, imageUrl, ImageLoader.ScaleType.START)) {
                                RequestOptions requestOptions = new RequestOptions()
                                        .override(childViewWidth, childViewHeight)
                                        .placeholder(placeholder)
                                        .fitCenter();
//                                        .override(Target.SIZE_ORIGINAL, Target.SIZE_ORIGINAL);

                                Glide.with(context)
                                        .load(imageUrl)
                                        .apply(requestOptions)
                                        .into((ImageView) view);

                                ((ImageView) view).setScaleType(ImageView.ScaleType.FIT_XY);
                            }
                        } catch (Exception e) {
                            //
                        }
                    } else if (data != null &&
                            data.getGist() != null &&
                            componentKey == AppCMSUIKeyType.PAGE_CAROUSEL_IMAGE_KEY) {
                        System.out.println("image dimen3- width" + childViewHeight + " width" + childViewWidth);
                        ((ImageView) view).setScaleType(ImageView.ScaleType.FIT_XY);

                        bringToFront = false;
                        int deviceWidth = getContext().getResources().getDisplayMetrics().widthPixels;
                        String imageUrl = "";
                        if (data.getGist() != null &&
                                data.getGist().getContentType() != null &&
                                ((data.getGist().getContentType().toLowerCase().contains(context.getString(R.string.content_type_audio).toLowerCase())) ||
                                        (data.getGist().getContentType().toLowerCase().contains(context.getString(R.string.app_cms_article_key_type).toLowerCase())))
                                && data.getGist().getImageGist() != null
                                && data.getGist().getImageGist().get_16x9() != null) {
                            imageUrl = data.getGist().getImageGist().get_16x9();
                        } else if (data.getGist() != null && data.getGist().getVideoImageUrl() != null) {
                            imageUrl = context.getString(R.string.app_cms_image_with_resize_query,
                                    data.getGist().getVideoImageUrl(),
                                    deviceWidth,
                                    childViewHeight);
                        }

                        try {
                            final int imageWidth = deviceWidth;
                            final int imageHeight = childViewHeight;

                            if (!ImageUtils.loadImageWithLinearGradient((ImageView) view,
                                    imageUrl,
                                    imageWidth,
                                    imageHeight)) {

                                Transformation gradientTransform = new GradientTransformation(imageWidth,
                                        imageHeight,
                                        appCMSPresenter,
                                        imageUrl);

                                RequestOptions requestOptions = new RequestOptions()
                                        .transform(gradientTransform)
                                        .placeholder(placeholder)
                                        .diskCacheStrategy(DiskCacheStrategy.RESOURCE)
                                        .override(imageWidth, imageHeight);
//                                        .override(Target.SIZE_ORIGINAL, Target.SIZE_ORIGINAL);

                                Glide.with(context)
                                        .load(imageUrl)
                                        .apply(requestOptions)
                                        .into((ImageView) view);
                            }
                        } catch (IllegalArgumentException e) {
                            //Log.e(TAG, "Failed to load image with Glide: " + e.toString());
                        }
                    } else if (data.getGist() != null &&
                            data.getGist().getImageGist() != null &&
                            data.getGist().getBadgeImages() != null &&
                            componentKey == AppCMSUIKeyType.PAGE_BADGE_IMAGE_KEY &&
                            0 < childViewWidth &&
                            0 < childViewHeight) {
                        if (childViewWidth < childViewHeight &&
                                data.getGist().getImageGist().get_3x4() != null &&
                                data.getGist().getBadgeImages().get_3x4() != null &&
                                componentKey == AppCMSUIKeyType.PAGE_BADGE_IMAGE_KEY &&
                                0 < childViewWidth &&
                                0 < childViewHeight) {
                            ((ImageView) view).setScaleType(ImageView.ScaleType.FIT_CENTER);

                            String imageUrl = context.getString(R.string.app_cms_image_with_resize_query,
                                    data.getGist().getBadgeImages().get_3x4(),
                                    childViewWidth,
                                    childViewHeight);

                            if (!ImageUtils.loadImage((ImageView) view, imageUrl, ImageLoader.ScaleType.START)) {
                                RequestOptions requestOptions = new RequestOptions()
                                        .override(childViewWidth, childViewHeight)
                                        .fitCenter()
                                        .placeholder(placeholder);
//                                        .override(Target.SIZE_ORIGINAL, Target.SIZE_ORIGINAL);
                                Glide.with(context)
                                        .load(imageUrl)
                                        .apply(requestOptions)
                                        .into((ImageView) view);
                            }
                        } else if (data.getGist().getImageGist().get_16x9() != null &&
                                data.getGist().getBadgeImages().get_16x9() != null) {
                            String imageUrl = context.getString(R.string.app_cms_image_with_resize_query,
                                    data.getGist().getBadgeImages().get_16x9(),
                                    childViewWidth,
                                    childViewHeight);
                            ((ImageView) view).setScaleType(ImageView.ScaleType.FIT_CENTER);

                            if (appCMSPresenter.isVideoDownloaded(data.getGist().getId())) {
                                if (data.getGist().getVideoImageUrl() != null) {
                                    imageUrl = data.getGist().getVideoImageUrl();
                                }
                            }
                            if (!ImageUtils.loadImage((ImageView) view, imageUrl, ImageLoader.ScaleType.START)) {
                                RequestOptions requestOptions = new RequestOptions()
                                        .override(childViewWidth, childViewHeight)
                                        .placeholder(R.drawable.img_placeholder)
                                        .fitCenter();
//                                        .override(Target.SIZE_ORIGINAL, Target.SIZE_ORIGINAL);
                                Glide.with(context)
                                        .load(imageUrl)
                                        .apply(requestOptions)
                                        .into((ImageView) view);
                            }
                        }
                        view.setVisibility(VISIBLE);
                        bringToFront = true;
                    } else if (componentKey == AppCMSUIKeyType.PAGE_BADGE_IMAGE_KEY) {
                        view.setVisibility(GONE);
                        bringToFront = false;
                    } else if (componentKey == AppCMSUIKeyType.PAGE_PHOTO_GALLERY_IMAGE_KEY) {

                        String imageUrl = data.getGist().getVideoImageUrl();
                        ImageView imageView = (ImageView) view;
                        imageView.setScaleType(ImageView.ScaleType.FIT_XY);
                        RequestOptions requestOptions = new RequestOptions()
                                .override(childViewWidth, childViewHeight)
                                .placeholder(placeholder);

                        Glide.with(context)
                                .load(imageUrl)
                                .apply(requestOptions)
                                .into(imageView);
                        ((ImageView) view).setScaleType(ImageView.ScaleType.FIT_XY);
                    }
                    if (appCMSUIcomponentViewType == AppCMSUIKeyType.PAGE_AUDIO_TRAY_MODULE_KEY) {
                        int size = childViewWidth;
                        if (childViewWidth < childViewHeight) {
                            size = childViewHeight;
                        }
                        int horizontalMargin = 0;
                        horizontalMargin = (int) getHorizontalMargin(getContext(), childComponent.getLayout());
                        int verticalMargin = (int) getVerticalMargin(getContext(), parentLayout, size, 0);
                        if (verticalMargin < 0) {
                            verticalMargin = (int) convertVerticalValue(getContext(), getYAxis(getContext(), getLayout(), 0));
                        }
//                        ((ImageView) view).setScaleType(ImageView.ScaleType.FIT_CENTER);
                        LayoutParams llParams = new LayoutParams(size, size);
                        llParams.setMargins(horizontalMargin,
                                verticalMargin,
                                horizontalMargin,
                                verticalMargin);
                        view.setLayoutParams(llParams);

                        if (data.getGist() != null &&
                                data.getGist().getImageGist() != null &&
                                data.getGist().getImageGist().get_1x1() != null && (componentKey == AppCMSUIKeyType.PAGE_THUMBNAIL_IMAGE_KEY)) {
                            String imageUrl = data.getGist().getImageGist().get_1x1();
                            ((ImageView) view).setScaleType(ImageView.ScaleType.FIT_CENTER);

                            if (appCMSPresenter.isVideoDownloaded(data.getGist().getId())) {
                                if (data.getGist().getVideoImageUrl() != null) {
                                    imageUrl = data.getGist().getVideoImageUrl();
                                }
                            }
//                            RequestOptions requestOptions = new RequestOptions().placeholder(placeholder);
                            RequestOptions requestOptions = new RequestOptions()
                                    .override(childViewWidth, childViewHeight).placeholder(placeholder)
                                    .fitCenter();
                            if (!ImageUtils.loadImage((ImageView) view, imageUrl, ImageLoader.ScaleType.START) && context != null && appCMSPresenter != null && appCMSPresenter.getCurrentActivity() != null && !appCMSPresenter.getCurrentActivity().isFinishing()) {
                                Glide.with(context.getApplicationContext())
                                        .load(imageUrl).apply(requestOptions)
//                                        .override(size,size)
                                        .into(((ImageView) view));
                            }
                        } else {
                            ((ImageView) view).setScaleType(ImageView.ScaleType.FIT_XY);
                            ((ImageView) view).setImageResource(R.drawable.vid_image_placeholder_square);
                        }

                    }
                    if (moduleType == AppCMSUIKeyType.PAGE_SEASON_TRAY_MODULE_KEY) {
                        view.setOnClickListener(v -> onClickHandler.click(CollectionGridItemView.this,
                                childComponent, data, position));
                    }
                }
            } else if (componentType == AppCMSUIKeyType.PAGE_BUTTON_KEY) {
                if (componentKey == AppCMSUIKeyType.PAGE_PLAY_IMAGE_KEY) {
                    ((TextView) view).setText("");
                } else if (componentKey == AppCMSUIKeyType.PAGE_PLAN_PURCHASE_BUTTON_KEY) {
                    ((TextView) view).setText(childComponent.getText());
                    view.setBackgroundColor(ContextCompat.getColor(getContext(),
                            R.color.disabledButtonColor));
                    viewsToUpdateOnClickEvent.add(view);
                } else if (componentKey == AppCMSUIKeyType.PAGE_GRID_OPTION_KEY) {
                    if (viewTypeKey == AppCMSUIKeyType.PAGE_ARTICLE_TRAY_KEY) {
                        ((Button) view).setBackground(context.getDrawable(R.drawable.dots_more_grey));
                        ((Button) view).getBackground().setTint(appCMSPresenter.getGeneralTextColor());
                        ((Button) view).getBackground().setTintMode(PorterDuff.Mode.MULTIPLY);
                    }
                } else if (componentKey == AppCMSUIKeyType.PAGE_VIDEO_DOWNLOAD_BUTTON_KEY ||
                        componentKey == AppCMSUIKeyType.PAGE_AUDIO_DOWNLOAD_BUTTON_KEY) {

                    String userId = appCMSPresenter.getLoggedInUser();

                    try {
                        int radiusDifference = 5;
                        if (BaseView.isTablet(context)) {
                            radiusDifference = 2;
                        }
                        ViewCreator.UpdateDownloadImageIconAction updateDownloadImageIconAction =
                                updateDownloadImageIconActionMap.get(data.getGist().getId());
                        if (updateDownloadImageIconAction == null) {
                            updateDownloadImageIconAction = new ViewCreator.UpdateDownloadImageIconAction((ImageButton) view, appCMSPresenter,
                                    data, userId, radiusDifference, moduleId);
                            updateDownloadImageIconActionMap.put(data.getGist().getId(), updateDownloadImageIconAction);
                        }

                        view.setTag(data.getGist().getId());

                        updateDownloadImageIconAction.updateDownloadImageButton((ImageButton) view);

                        appCMSPresenter.getUserVideoDownloadStatus(
                                data.getGist().getId(), updateDownloadImageIconAction, userId);
                    } catch (Exception e) {

                    }
                } /*else if (componentKey == AppCMSUIKeyType.PAGE_AUDIO_DOWNLOAD_BUTTON_KEY) {
                 *//*view.setOnClickListener(v -> onClickHandler.click(CollectionGridItemView.this,
                            childComponent, data, position));*//*
                    if (appCMSPresenter.isVideoDownloaded(data.getGist().getId())) {
                        ((ImageButton) view).setImageResource(R.drawable.ic_downloaded_big);
                        view.setOnClickListener(null);
                    } else if (appCMSPresenter.isVideoDownloading(data.getGist().getId())) {
                        int radiusDifference = 5;
                        if (BaseView.isTablet(context)) {
                            radiusDifference = 2;
                        }
                        appCMSPresenter.updateDownloadingStatus(
                                data.getGist().getId(),
                                (ImageButton) view,
                                appCMSPresenter,
                                new ViewCreator.UpdateDownloadImageIconAction(
                                        (ImageButton) view,
                                        appCMSPresenter,
                                        data,
                                        appCMSPresenter.getLoggedInUser(),
                                        radiusDifference,
                                        moduleId),
                                appCMSPresenter.getLoggedInUser(),
                                false,
                                radiusDifference,
                                moduleId);
                        view.setOnClickListener(null);
                    }
                } */ else {
                    view.setOnClickListener(v -> onClickHandler.click(CollectionGridItemView.this,
                            childComponent, data, position));
                }
            } else if (componentType == AppCMSUIKeyType.PAGE_GRID_OPTION_KEY) {
                view.setOnClickListener(v ->
                        onClickHandler.click(CollectionGridItemView.this,
                                childComponent, data, position));
            } else if (componentType == AppCMSUIKeyType.PAGE_LABEL_KEY &&
                    view instanceof TextView) {
                if (TextUtils.isEmpty(((TextView) view).getText())) {
                    if (componentKey == AppCMSUIKeyType.PAGE_CAROUSEL_TITLE_KEY &&
                            !TextUtils.isEmpty(data.getGist().getTitle())) {
                        ((TextView) view).setText(data.getGist().getTitle());

                        //((TextView) view).setEllipsize(TextUtils.TruncateAt.END);
                        if (component != null &&
                                component.getView() != null &&
                                component.getView().equalsIgnoreCase(context.getResources().getString(R.string.app_cms_page_event_carousel_module_key))) {
                            if (childComponent.getNumberOfLines() != 0) {
                                ((TextView) view).setSingleLine(false);
                                ((TextView) view).setMaxLines(childComponent.getNumberOfLines());
                                ((TextView) view).setEllipsize(TextUtils.TruncateAt.END);
                            }
                            if (BaseView.isTablet(view.getContext())) {
                                if(isLandscape(getContext()) == true) {
                                    ((TextView) view).setBackgroundColor(Color.TRANSPARENT);
                                    ((TextView) view).setTextColor(appCMSPresenter.getBrandPrimaryCtaTextColor());
                                }else{
                                    setBorder(((TextView) view));
                                    ((TextView) view).setTextColor(Color.parseColor("#FFFFFF"));
                                }
                            } else {
                                ((TextView) view).setBackgroundColor(Color.TRANSPARENT);
                                ((TextView) view).setTextColor(appCMSPresenter.getGeneralTextColor());
                            }
                        }else{
                            if (BaseView.isTablet(view.getContext()) && isLandscape(getContext()) == true) {
                                ((TextView) view).setTextColor(appCMSPresenter.getBrandPrimaryCtaTextColor());
                            }else{
                                ((TextView) view).setTextColor(Color.parseColor(
                                        childComponent.getTextColor()));
                            }
                        }
                    } else if (componentKey == AppCMSUIKeyType.PAGE_CAROUSEL_INFO_KEY) {
                        if (data.getGist().getMediaType() != null && data.getGist().getMediaType().equalsIgnoreCase("AUDIO")) {
                            if (data.getCreditBlocks() != null && data.getCreditBlocks().size() > 0 && data.getCreditBlocks().get(0).getCredits() != null && data.getCreditBlocks().get(0).getCredits().size() > 0 && data.getCreditBlocks().get(0).getCredits().get(0).getTitle() != null) {
                                String artist = appCMSPresenter.getArtistNameFromCreditBlocks(data.getCreditBlocks());
                                ((TextView) view).setMaxLines(1);
                                ((TextView) view).setEllipsize(TextUtils.TruncateAt.END);
                                ((TextView) view).setText(artist);
                                view.setPadding(10,
                                        0,
                                        10,
                                        0);
                            }

                        } else if (data.getSeason() != null && 0 < data.getSeason().size()) {
                            ViewCreator.setViewWithShowSubtitle(getContext(), data, view, true);
                        } else {
                            ViewCreator.setViewWithSubtitle(getContext(), data, view);
                        }
                        if (TextUtils.isEmpty(((TextView) view).getText().toString())) {
                            view.setVisibility(INVISIBLE);
                        } else {
                            view.setVisibility(VISIBLE);
                        }
                        if (BaseView.isTablet(view.getContext()) && BaseView.isLandscape(context) == true) {
                            ((TextView) view).setTextColor(appCMSPresenter.getBrandPrimaryCtaTextColor());
                        }else{
                            ((TextView) view).setTextColor(Color.parseColor("#FFFFFF"));
                        }

                    } else if (componentKey == AppCMSUIKeyType.PAGE_THUMBNAIL_TITLE_KEY ||
                            componentKey == AppCMSUIKeyType.PAGE_ARTICLE_FEED_BOTTOM_TEXT_KEY) {
                        if (childComponent.getNumberOfLines() != 0) {
                            ((TextView) view).setSingleLine(false);
                            ((TextView) view).setMaxLines(childComponent.getNumberOfLines());
                            ((TextView) view).setEllipsize(TextUtils.TruncateAt.END);
                        }
                        if (componentKey == AppCMSUIKeyType.PAGE_ARTICLE_FEED_BOTTOM_TEXT_KEY) {
                            ((TextView) view).setGravity(Gravity.RIGHT);
                            StringBuffer publishDate = new StringBuffer();
                            if (data.getContentDetails().getAuthor().getPublishDate() != null) {
                                publishDate.append("|");
                                publishDate.append(data.getContentDetails().getAuthor().getPublishDate().toString());
                            }
                            ((TextView) view).setText(data.getContentDetails().getAuthor().getName() + publishDate.toString());
                        } else {
                            ((TextView) view).setText(data.getGist().getTitle());
                        }
                        ((TextView) view).setTextColor(appCMSPresenter.getGeneralTextColor());
                        /*if (!TextUtils.isEmpty(childComponent.getTextColor())) {
                            int textColor = Color.parseColor(getColor(getContext(),
                                    childComponent.getTextColor()));
                            ((TextView) view).setTextColor(textColor);
                        }*/

                    } else if (componentKey == AppCMSUIKeyType.PAGE_THUMBNAIL_DESCRIPTION_KEY) {
                        if (childComponent.getNumberOfLines() != 0) {
                            ((TextView) view).setSingleLine(false);
                            ((TextView) view).setMaxLines(childComponent.getNumberOfLines());
                            ((TextView) view).setEllipsize(TextUtils.TruncateAt.END);
                        }
                        ((TextView) view).setText(data.getGist().getDescription());
                        if (!TextUtils.isEmpty(childComponent.getTextColor())) {
                            int textColor = Color.parseColor(getColor(getContext(),
                                    childComponent.getTextColor()));
                            ((TextView) view).setTextColor(textColor);
                        }
                    } else if (componentKey == AppCMSUIKeyType.PAGE_THUMBNAIL_READ_MORE_KEY) {
                        ((TextView) view).setText(childComponent.getText());
                        if (!TextUtils.isEmpty(childComponent.getTextColor())) {
                            int textColor = Color.parseColor(getColor(getContext(),
                                    childComponent.getTextColor()));
                            ((TextView) view).setTextColor(textColor);
                        }
                    } else if (componentKey == AppCMSUIKeyType.PAGE_ARTICLE_TITLE_KEY && !TextUtils.isEmpty(data.getGist().getTitle())) {
                        ((TextView) view).setSingleLine(false);
                        ((TextView) view).setMaxLines(2);
                        ((TextView) view).setEllipsize(TextUtils.TruncateAt.END);
                        ((TextView) view).setText(data.getGist().getTitle());

                        if (!TextUtils.isEmpty(childComponent.getTextColor())) {
                            int textColor = Color.parseColor(getColor(getContext(),
                                    childComponent.getTextColor()));
                            ((TextView) view).setTextColor(textColor);
                        }
                    } else if (componentKey == AppCMSUIKeyType.PAGE_WATCHLIST_DURATION_KEY_BG) {

                        final int SECONDS_PER_MINS = 60;
                        if ((data.getGist().getRuntime() / SECONDS_PER_MINS) < 2) {
                            StringBuilder runtimeText = new StringBuilder()
                                    .append(data.getGist().getRuntime() / SECONDS_PER_MINS)
                                    .append(" ")
                                    .append(context.getString(R.string.min_abbreviation));

                            ((TextView) view).setText(runtimeText);
                        } else {
                            StringBuilder runtimeText = new StringBuilder()
                                    .append(data.getGist().getRuntime() / SECONDS_PER_MINS)
                                    .append(" ")
                                    .append(context.getString(R.string.mins_abbreviation));

                            ((TextView) view).setText(runtimeText);
                        }
                        ((TextView) view).setBackgroundColor(Color.parseColor("#4D000000"));
                        ((TextView) view).setTextColor(Color.parseColor("#ffffff"));
                    } else if (componentKey == AppCMSUIKeyType.PAGE_ARTICLE_DESCRIPTION_KEY && !TextUtils.isEmpty(data.getGist().getDescription())) {
                        ((TextView) view).setSingleLine(false);
                        ((TextView) view).setMaxLines(3);
                        ((TextView) view).setEllipsize(TextUtils.TruncateAt.END);
                        ((TextView) view).setText(data.getGist().getDescription());
                        if (!TextUtils.isEmpty(childComponent.getTextColor())) {
                            int textColor = Color.parseColor(getColor(getContext(),
                                    childComponent.getTextColor()));
                            ((TextView) view).setTextColor(textColor);
                        }
                    } else if (componentKey == AppCMSUIKeyType.PAGE_API_SUMMARY_TEXT_KEY && !TextUtils.isEmpty(data.getGist().getSummaryText())) {
                        if (childComponent.getNumberOfLines() != 0) {
                            ((TextView) view).setSingleLine(false);
                            ((TextView) view).setMaxLines(childComponent.getNumberOfLines());
                            ((TextView) view).setEllipsize(TextUtils.TruncateAt.END);
                        }
                        ((TextView) view).setText(data.getGist().getSummaryText());
                    } else if (componentKey == AppCMSUIKeyType.PAGE_DELETE_DOWNLOAD_VIDEO_SIZE_KEY) {
                        ((TextView) view).setText(appCMSPresenter.getDownloadedFileSize(data.getGist().getId()));
                    } else if (componentKey == AppCMSUIKeyType.PAGE_HISTORY_WATCHED_TIME_KEY) {
                        ((TextView) view).setText(appCMSPresenter.getLastWatchedTime(data));
                    } else if (componentKey == AppCMSUIKeyType.PAGE_HISTORY_DURATION_KEY ||
                            componentKey == AppCMSUIKeyType.PAGE_DOWNLOAD_DURATION_KEY) {
                        final int SECONDS_PER_MINS = 60;
                        if ((data.getGist().getRuntime() / SECONDS_PER_MINS) < 2) {
                            StringBuilder runtimeText = new StringBuilder()
                                    .append(data.getGist().getRuntime() / SECONDS_PER_MINS)
                                    .append(" ")
                                    .append(context.getString(R.string.min_abbreviation));
                            ((TextView) view).setText(runtimeText);
                        } else {
                            StringBuilder runtimeText = new StringBuilder()
                                    .append(data.getGist().getRuntime() / SECONDS_PER_MINS)
                                    .append(" ")
                                    .append(context.getString(R.string.mins_abbreviation));
                            ((TextView) view).setText(runtimeText);
                        }
                    } else if (componentKey == AppCMSUIKeyType.PAGE_WATCHLIST_DURATION_KEY) {
                        final int SECONDS_PER_MINS = 60;
                        if ((data.getGist().getRuntime() / SECONDS_PER_MINS) < 2) {
                            StringBuilder runtimeText = new StringBuilder()
                                    .append(data.getGist().getRuntime() / SECONDS_PER_MINS)
                                    .append(" ")
                                    //min value is being set in unit tag under PAGE_WATCHLIST_DURATION_UNIT_KEY component key so removing
                                    //unit abbrevation from here .Its causing double visibilty of time unit
                                    .append(context.getString(R.string.min_abbreviation));
                            ((TextView) view).setText(runtimeText);
                            ((TextView) view).setVisibility(View.VISIBLE);

                        } else {
                            StringBuilder runtimeText = new StringBuilder()
                                    .append(data.getGist().getRuntime() / SECONDS_PER_MINS)
                                    .append(" ")
                                    .append(context.getString(R.string.mins_abbreviation));
                            ((TextView) view).setText(runtimeText);
                            ((TextView) view).setVisibility(View.VISIBLE);
                        }
                    } else if (componentKey == AppCMSUIKeyType.PAGE_AUDIO_DURATION_KEY) {
                        String time = appCMSPresenter.audioDuration((int) data.getGist().getRuntime());
                        ((TextView) view).setText(time);
                    } else if (componentKey == AppCMSUIKeyType.PAGE_WATCHLIST_DURATION_UNIT_KEY) {
                        ((TextView) view).setText(context.getResources().getQuantityString(R.plurals.min_duration_unit,
                                (int) (data.getGist().getRuntime() / 60)));

                        ViewCreator.UpdateDownloadImageIconAction updateDownloadImageIconAction =
                                updateDownloadImageIconActionMap.get(data.getGist().getId());
                        if (updateDownloadImageIconAction != null) {
                            view.setClickable(true);
                            view.setOnClickListener(updateDownloadImageIconAction.getAddClickListener());
                        }
                        ((TextView) view).setVisibility(View.VISIBLE);

                    } else if (componentKey == AppCMSUIKeyType.PAGE_GRID_THUMBNAIL_INFO) {

                        if (data.getGist().getMediaType() != null && data.getGist().getMediaType().toLowerCase().contains(context.getString(R.string.app_cms_photo_gallery_key_type).toLowerCase())) {
                            StringBuilder thumbInfo = new StringBuilder();
                            if (data.getGist().getPublishDate() != null) {
                                thumbInfo.append(getDateFormat(Long.parseLong(data.getGist().getPublishDate()), "MMM dd"));
                            }
                            int noOfPhotos = 0;
                            if (data.getStreamingInfo() != null && data.getStreamingInfo().getPhotogalleryAssets() != null && data.getStreamingInfo().getPhotogalleryAssets().size() > 0) {
                                if (thumbInfo.length() > 0) {
                                    thumbInfo.append(" | ");
                                }
                                noOfPhotos = data.getStreamingInfo().getPhotogalleryAssets().size();
                                thumbInfo.append(context.getResources().getQuantityString(R.plurals.no_of_photos, noOfPhotos, noOfPhotos));
                            }

                            ((TextView) view).setText(thumbInfo);
                        } else {
                            String thumbInfo = null;
                            if (data.getGist().getPublishDate() != null) {
                                thumbInfo = getDateFormat(Long.parseLong(data.getGist().getPublishDate()), "MMM dd");
                            }
                            if (data.getGist() != null && data.getGist().getReadTime() != null) {
                                StringBuilder readTimeText = new StringBuilder()
                                        .append(data.getGist().getReadTime().trim())
                                        .append("min")
                                        .append(" read ");

                                if (thumbInfo != null && thumbInfo.length() > 0) {
                                    readTimeText.append("|")
                                            .append(" ")
                                            .append(thumbInfo);
                                }
                                ((TextView) view).setText(readTimeText);
                            } else {
                                long runtime = data.getGist().getRuntime();
                                if (thumbInfo != null && runtime > 0) {
                                    ((TextView) view).setText(AppCMSPresenter.convertSecondsToTime(runtime) + " | " + thumbInfo);
                                } else {
                                    if (thumbInfo != null) {
                                        ((TextView) view).setText(thumbInfo);
                                    } else if (runtime > 0) {
                                        ((TextView) view).setText(AppCMSPresenter.convertSecondsToTime(runtime));
                                    }
                                }

                            }
                        }
                    } else if (componentKey == AppCMSUIKeyType.PAGE_GRID_PHOTO_GALLERY_THUMBNAIL_INFO) {
                        StringBuilder thumbInfo = new StringBuilder();
                        if (data.getGist().getPublishDate() != null) {
                            thumbInfo.append(getDateFormat(Long.parseLong(data.getGist().getPublishDate()), "MMM dd"));
                        }
                        int noOfPhotos = 0;
                        if (data.getStreamingInfo() != null && data.getStreamingInfo().getPhotogalleryAssets() != null && data.getStreamingInfo().getPhotogalleryAssets().size() > 0) {
                            if (thumbInfo.length() > 0) {
                                thumbInfo.append(" | ");
                            }
                            noOfPhotos = data.getStreamingInfo().getPhotogalleryAssets().size();
                            thumbInfo.append(context.getResources().getQuantityString(R.plurals.no_of_photos, noOfPhotos, noOfPhotos));
                        }

                        ((TextView) view).setText(thumbInfo);
                    } else if (componentKey == AppCMSUIKeyType.PAGE_API_TITLE ||
                            componentKey == AppCMSUIKeyType.PAGE_EPISODE_TITLE_KEY) {
                        if (data.getGist() != null && data.getGist().getTitle() != null) {
                            ((TextView) view).setText(data.getGist().getTitle());
                            ((TextView) view).setSingleLine(true);
                            ((TextView) view).setEllipsize(TextUtils.TruncateAt.END);
                            ((TextView) view).setVisibility(View.VISIBLE);
                        }
                    } else if (componentKey == AppCMSUIKeyType.PAGE_HISTORY_DESCRIPTION_KEY ||
                            componentKey == AppCMSUIKeyType.PAGE_WATCHLIST_DESCRIPTION_KEY ||
                            componentKey == AppCMSUIKeyType.PAGE_DOWNLOAD_DESCRIPTION_KEY) {
                        if (data != null && data.getGist() != null && data.getGist().getDescription() != null) {
                            ((TextView) view).setSingleLine(false);
                            ((TextView) view).setMaxLines(2);
                            ((TextView) view).setEllipsize(TextUtils.TruncateAt.END);
                            ((TextView) view).setText(data.getGist().getDescription());

                            try {
                                ViewTreeObserver titleTextVto = view.getViewTreeObserver();
                                ViewCreatorMultiLineLayoutListener viewCreatorTitleLayoutListener =
                                        new ViewCreatorMultiLineLayoutListener((TextView) view,
                                                data.getGist().getTitle(),
                                                data.getGist().getDescription(),
                                                appCMSPresenter,
                                                true,
                                                Color.parseColor(appCMSPresenter.getAppCMSMain().getBrand().getCta().getPrimary().getTextColor()),
                                                false);
                                titleTextVto.addOnGlobalLayoutListener(viewCreatorTitleLayoutListener);
                            } catch (Exception e) {
                            }
                        }
                    } else if (componentKey == AppCMSUIKeyType.PAGE_PLAYLIST_AUDIO_ARTIST_TITLE) {
                        String artist = appCMSPresenter.getArtistNameFromCreditBlocks(data.getCreditBlocks());
                        ((TextView) view).setText(artist);
                        ((TextView) view).setTextColor(Color.parseColor(childComponent.getTextColor()));

                    } else if (componentKey == AppCMSUIKeyType.PAGE_API_DESCRIPTION) {
                        if (childComponent.getNumberOfLines() != 0) {
                            ((TextView) view).setSingleLine(false);
                            ((TextView) view).setMaxLines(childComponent.getNumberOfLines());
                            ((TextView) view).setEllipsize(TextUtils.TruncateAt.END);
                        }
                        ((TextView) view).setText(data.getGist().getDescription());
                        try {
                            ViewTreeObserver titleTextVto = view.getViewTreeObserver();
                            ViewCreatorMultiLineLayoutListener viewCreatorTitleLayoutListener =
                                    new ViewCreatorMultiLineLayoutListener((TextView) view,
                                            data.getGist().getTitle(),
                                            data.getGist().getDescription(),
                                            appCMSPresenter,
                                            false,
                                            Color.parseColor(appCMSPresenter.getAppCMSMain().getBrand().getCta().getPrimary().getTextColor()),
                                            true);
                            titleTextVto.addOnGlobalLayoutListener(viewCreatorTitleLayoutListener);
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                        ((TextView) view).setVisibility(View.VISIBLE);
                    } else if (componentKey == AppCMSUIKeyType.PAGE_PLAN_TITLE_KEY) {
                        ((TextView) view).setText(data.getName());
                        if (componentType.equals(AppCMSUIKeyType.PAGE_SUBSCRIPTION_SELECTPLAN_02_KEY) ||
                                componentType.equals(AppCMSUIKeyType.PAGE_SUBSCRIPTION_SELECTPLAN_01_KEY)) {
                            ((TextView) view).setTextColor(themeColor);
                        } else {
                            ((TextView) view).setTextColor(Color.parseColor(childComponent.getTextColor()));
                        }
                    } else if (componentKey == AppCMSUIKeyType.PAGE_PLAN_PRICEINFO_KEY) {
                        int planIndex = 0;

                        for (int i = 0; i < data.getPlanDetails().size(); i++) {
                            if (data.getPlanDetails().get(i) != null &&
                                    data.getPlanDetails().get(i).getIsDefault()) {
                                planIndex = i;
                            }
                        }

                        Currency currency = null;
                        if (data.getPlanDetails() != null &&
                                !data.getPlanDetails().isEmpty() &&
                                data.getPlanDetails().get(planIndex) != null &&
                                data.getPlanDetails().get(planIndex).getRecurringPaymentCurrencyCode() != null) {
                            try {
                                currency = Currency.getInstance(data.getPlanDetails().get(planIndex).getRecurringPaymentCurrencyCode());
                            } catch (Exception e) {
                                //Log.e(TAG, "Could not parse locale");
                            }
                        }

                        if (data.getPlanDetails() != null &&
                                !data.getPlanDetails().isEmpty() &&
                                data.getPlanDetails().get(planIndex) != null &&
                                data.getPlanDetails().get(planIndex).getStrikeThroughPrice() != 0) {

                            double recurringPaymentAmount = data.getPlanDetails().get(planIndex).getRecurringPaymentAmount();
                            String formattedRecurringPaymentAmount = context.getString(R.string.cost_with_fraction,
                                    recurringPaymentAmount);
                            if (recurringPaymentAmount - (int) recurringPaymentAmount == 0) {
                                formattedRecurringPaymentAmount = context.getString(R.string.cost_without_fraction,
                                        recurringPaymentAmount);
                            }

                            double strikeThroughPaymentAmount = data.getPlanDetails()
                                    .get(planIndex).getStrikeThroughPrice();
                            String formattedStrikeThroughPaymentAmount = context.getString(R.string.cost_with_fraction,
                                    strikeThroughPaymentAmount);
                            if (strikeThroughPaymentAmount - (int) strikeThroughPaymentAmount == 0) {
                                formattedStrikeThroughPaymentAmount = context.getString(R.string.cost_without_fraction,
                                        strikeThroughPaymentAmount);
                            }

                            StringBuilder stringBuilder = new StringBuilder();
                            if (currency != null) {
                                stringBuilder.append(currency.getSymbol());
                            }
                            stringBuilder.append(formattedStrikeThroughPaymentAmount);

                            if (data.getPlanDetails().get(0).getRecurringPaymentAmount() != 0) {
                                int strikeThroughLength = stringBuilder.length();
                                stringBuilder.append("     ");
                                if (currency != null) {
                                    stringBuilder.append(currency.getSymbol());
                                }
                                stringBuilder.append(String.valueOf(formattedRecurringPaymentAmount));

                                SpannableString spannableString =
                                        new SpannableString(stringBuilder.toString());
                                spannableString.setSpan(new StrikethroughSpan(), 0,
                                        strikeThroughLength, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
                                ((TextView) view).setText(spannableString);
                            } else {
                                ((TextView) view).setText(stringBuilder.toString());
                            }
                        } else {
                            double recurringPaymentAmount = data.getPlanDetails()
                                    .get(planIndex).getRecurringPaymentAmount();
                            String formattedRecurringPaymentAmount = context.getString(R.string.cost_with_fraction,
                                    recurringPaymentAmount);
                            if (recurringPaymentAmount - (int) recurringPaymentAmount == 0) {
                                formattedRecurringPaymentAmount = context.getString(R.string.cost_without_fraction,
                                        recurringPaymentAmount);
                            }

                            StringBuilder stringBuilder = new StringBuilder();
                            if (currency != null) {
                                stringBuilder.append(currency.getSymbol());
                            }

                            stringBuilder.append(formattedRecurringPaymentAmount);
                            if (appCMSUIcomponentViewType == AppCMSUIKeyType.PAGE_SUBSCRIPTION_SELECTPLAN_01_KEY) {
                                if (data.getRenewalCycleType().contains(context.getString(R.string.app_cms_plan_renewal_cycle_type_monthly))) {
                                    stringBuilder.append(" ");
                                    stringBuilder.append(context.getString(R.string.forward_slash));
                                    stringBuilder.append(" ");
                                    stringBuilder.append(context.getString(R.string.plan_type_month));
                                }
                                if (data.getRenewalCycleType().contains(context.getString(R.string.app_cms_plan_renewal_cycle_type_yearly))) {
                                    stringBuilder.append(" ");
                                    stringBuilder.append(context.getString(R.string.forward_slash));
                                    stringBuilder.append(" ");
                                    stringBuilder.append(context.getString(R.string.plan_type_year));
                                }
                                if (data.getRenewalCycleType().contains(context.getString(R.string.app_cms_plan_renewal_cycle_type_daily))) {
                                    stringBuilder.append(" ");
                                    stringBuilder.append(context.getString(R.string.forward_slash));
                                    stringBuilder.append(" ");
                                    stringBuilder.append(context.getString(R.string.plan_type_day));
                                }
                            }
                            ((TextView) view).setText(stringBuilder.toString());
                            ((TextView) view).setPaintFlags(((TextView) view).getPaintFlags());
                        }

                        ((TextView) view).setTextColor(appCMSPresenter.getGeneralTextColor());

                    } else if (componentKey == AppCMSUIKeyType.PAGE_PLAN_BESTVALUE_KEY) {
                        ((TextView) view).setText(childComponent.getText());
                        ((TextView) view).setTextColor(Color.parseColor(
                                childComponent.getTextColor()));
                    } else if (componentKey == AppCMSUIKeyType.PAGE_PLAN_BESTVALUE_KEY) {
                        ((TextView) view).setText(childComponent.getText());
                        ((TextView) view).setTextColor(Color.parseColor(
                                childComponent.getTextColor()));
                    } else {
                        ((TextView) view).setTextColor(appCMSPresenter.getGeneralTextColor());
                    }
                }
            } else if (componentType == AppCMSUIKeyType.PAGE_PLAN_META_DATA_VIEW_KEY) {
                if (view instanceof ViewPlansMetaDataView) {
                    ((ViewPlansMetaDataView) view).setData(data);
                }

                if (view instanceof SubscriptionMetaDataView) {
                    ((SubscriptionMetaDataView) view).setData(data);
                }
            } else if (componentType == AppCMSUIKeyType.PAGE_SUBSCRIPTION_SELECTPLAN_02_KEY ||
                    componentType == AppCMSUIKeyType.PAGE_SUBSCRIPTION_SELECTPLAN_01_KEY) {
                view.setBackgroundColor(getResources().getColor(R.color.colorAccent));
            } else if (componentType == AppCMSUIKeyType.PAGE_PROGRESS_VIEW_KEY) {
                if (view instanceof ProgressBar) {
                    ContentDatum historyData = null;
                    if (data != null && data.getGist() != null && data.getGist().getId() != null) {
                        historyData = appCMSPresenter.getUserHistoryContentDatum(data.getGist().getId());
                    }

                    int progress = 0;

                    if (historyData != null) {
                        data.getGist().setWatchedPercentage(historyData.getGist().getWatchedPercentage());
                        data.getGist().setWatchedTime(historyData.getGist().getWatchedTime());
                        if (historyData.getGist().getWatchedPercentage() > 0) {
                            progress = historyData.getGist().getWatchedPercentage();
                            view.setVisibility(View.VISIBLE);
                            ((ProgressBar) view).setProgress(progress);
                        } else {
                            long watchedTime = historyData.getGist().getWatchedTime();
                            long runTime = historyData.getGist().getRuntime();
                            if (watchedTime > 0 && runTime > 0) {
                                long percentageWatched = (long) (((double) watchedTime / (double) runTime) * 100.0);
                                progress = (int) percentageWatched;
                                ((ProgressBar) view).setProgress(progress);
                                view.setVisibility(View.VISIBLE);
                            } else {
                                view.setVisibility(View.INVISIBLE);
                                ((ProgressBar) view).setProgress(0);
                            }
                        }
                    } else {
                        view.setVisibility(View.INVISIBLE);
                    }
                }
            }

            if (shouldShowView(childComponent) && bringToFront) {
                view.bringToFront();
            }
            view.forceLayout();
        }
    }

    private void setBorder(View itemView) {
        GradientDrawable planBorder = new GradientDrawable(GradientDrawable.Orientation.TOP_BOTTOM,
                new int[]{Color.TRANSPARENT, Color.parseColor("#000000")});
        planBorder.setShape(GradientDrawable.RECTANGLE);
        planBorder.setCornerRadius(0f);
        itemView.setBackground(planBorder);
    }

    public Component matchComponentToView(View view) {
        for (ItemContainer itemContainer : childItems) {
            if (itemContainer.childView == view) {
                return itemContainer.component;
            }
        }
        return null;
    }

    public List<View> getViewsToUpdateOnClickEvent() {
        return viewsToUpdateOnClickEvent;
    }

    private String getDateFormat(long timeMilliSeconds, String dateFormat) {
        SimpleDateFormat formatter = new SimpleDateFormat(dateFormat);

        // Create a calendar object that will convert the date and time value in milliseconds to date.
        Calendar calendar = Calendar.getInstance();
        calendar.setTimeInMillis(timeMilliSeconds);
        return formatter.format(calendar.getTime());
    }

    public List<ItemContainer> getChildItems() {
        return childItems;
    }

    private String getColor(Context context, String color) {
        if (color.indexOf(context.getString(R.string.color_hash_prefix)) != 0) {
            return context.getString(R.string.color_hash_prefix) + color;
        }
        return color;
    }

    public String getSubstring(String value, int maxLength) {
        if (!TextUtils.isEmpty(value)) {
            if (value.length() >= maxLength) {
                return value.substring(0, maxLength) + "...";
            }
        }
        return value;
    }

    public interface OnClickHandler {
        void click(CollectionGridItemView collectionGridItemView,
                   Component childComponent,
                   ContentDatum data, int clickPosition);

        void play(Component childComponent, ContentDatum data);
    }

    public static class ItemContainer {
        View childView;
        Component component;

        public View getChildView() {
            return childView;
        }

        public Component getComponent() {
            return component;
        }

        public static class Builder {
            private ItemContainer itemContainer;

            public Builder() {
                itemContainer = new ItemContainer();
            }

            Builder childView(View childView) {
                itemContainer.childView = childView;
                return this;
            }

            public Builder component(Component component) {
                itemContainer.component = component;
                return this;
            }

            public ItemContainer build() {
                return itemContainer;
            }
        }
    }

    private static class GradientTransformation extends BitmapTransformation {
        private final String ID;

        private int imageWidth, imageHeight;
        private AppCMSPresenter appCMSPresenter;
        private String imageUrl;

        public GradientTransformation(int imageWidth,
                                      int imageHeight,
                                      AppCMSPresenter appCMSPresenter,
                                      String imageUrl) {
            this.imageWidth = imageWidth;
            this.imageHeight = imageHeight;
            this.appCMSPresenter = appCMSPresenter;
            this.imageUrl = imageUrl;
            this.ID = imageUrl;
        }

        @Override
        public boolean equals(Object obj) {
            return obj instanceof GradientTransformation;
        }

        @Override
        public void updateDiskCacheKey(@NonNull MessageDigest messageDigest) {
            try {
                byte[] ID_BYTES = ID.getBytes(STRING_CHARSET_NAME);
                messageDigest.update(ID_BYTES);
            } catch (UnsupportedEncodingException e) {
                Log.e(TAG, "Could not update disk cache key: " + e.getMessage());
            }
        }

        @Override
        protected Bitmap transform(BitmapPool pool, Bitmap toTransform,
                                   int outWidth, int outHeight) {
            int width = toTransform.getWidth();
            int height = toTransform.getHeight();

            boolean scaleImageUp = false;

            Bitmap sourceWithGradient;
            if (width < imageWidth &&
                    height < imageHeight) {
                scaleImageUp = true;
                float widthToHeightRatio =
                        (float) width / (float) height;
                width = (int) (imageHeight * widthToHeightRatio);
                height = imageHeight;
                sourceWithGradient =
                        Bitmap.createScaledBitmap(toTransform,
                                width,
                                height,
                                false);
            } else {
                sourceWithGradient =
                        Bitmap.createBitmap(width,
                                height,
                                Bitmap.Config.ARGB_8888);
            }

            Canvas canvas = new Canvas(sourceWithGradient);
            if (!scaleImageUp) {
                canvas.drawBitmap(toTransform, 0, 0, null);
            }

            Paint paint = new Paint();
            LinearGradient shader = new LinearGradient(0,
                    0,
                    0,
                    height,
                    0xFFFFFFFF,
                    0xFF000000,
                    Shader.TileMode.CLAMP);
            paint.setShader(shader);
            paint.setXfermode(new PorterDuffXfermode(PorterDuff.Mode.MULTIPLY));
            canvas.drawRect(0, 0, width, height, paint);
            paint = null;
            return sourceWithGradient;
        }

        @Override
        public int hashCode() {
            return ID.hashCode();
        }
    }

}
