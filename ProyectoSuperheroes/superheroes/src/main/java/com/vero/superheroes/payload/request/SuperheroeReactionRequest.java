package com.vero.superheroes.payload.request;

import jakarta.validation.constraints.NotBlank;

public class SuperheroeReactionRequest {
  private Long superheroeId;
  public Long getSuperheroeId() {
    return superheroeId;
}

  public void setSuperheroeId(Long superheroeId) {
    this.superheroeId = superheroeId;
  }

  private Long reactionId;

  public Long getReactionId() {
    return reactionId;
  }

  public void setReactionId(Long reactionId) {
    this.reactionId = reactionId;
  }


}