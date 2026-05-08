package com.vero.superheroes.payload.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public class CommentRequest {

    @NotNull
    private Long superheroeId;

    @NotBlank
    private String content;

    public Long getSuperheroeId() {
        return superheroeId;
    }

    public void setSuperheroeId(Long superheroeId) {
        this.superheroeId = superheroeId;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }
}