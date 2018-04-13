package com.viewlift.models.data.appcms.api;

import com.google.gson.annotations.Expose;

/**
 * Created by ram.kailash on 2/14/2018.
 */

public class PhotoGalleryData {

    @Expose
    private String id;
    @Expose
    private String secureUrl;
    @Expose
    private String name;
    @Expose
    private String alt;
    @Expose
    private String caption;
    @Expose
    private String description;
    @Expose
    private String imageType;
    @Expose
    private String url;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getSecureUrl() {
        return secureUrl;
    }

    public void setSecureUrl(String secureUrl) {
        this.secureUrl = secureUrl;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getAlt() {
        return alt;
    }

    public void setAlt(String alt) {
        this.alt = alt;
    }

    public String getCaption() {
        return caption;
    }

    public void setCaption(String caption) {
        this.caption = caption;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getImageType() {
        return imageType;
    }

    public void setImageType(String imageType) {
        this.imageType = imageType;
    }

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }
}
