package com.vero.superheroes.models;
import com.fasterxml.jackson.annotation.JsonIgnore;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.MapsId;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;

@Entity
@Table( name = "tweet_reactions",
          uniqueConstraints = { 
                    @UniqueConstraint(columnNames = {"user_id", "superheroe_id"}
          ),
      
        }
)

public class SuperheroeReaction {

   @Id
   @GeneratedValue(strategy = GenerationType.IDENTITY)
   private Long id;
 
   @Column(name = "reaction_id")
   Long reactionId;

   public Long getReactionId() {
    return reactionId;
}

   public void setReactionId(Long reactionId) {
    this.reactionId = reactionId;
   }

   @Column(name = "user_id")
   Long userId;

    public Long getUserId() {
    return userId;
}

   public void setUserId(Long userId) {
    this.userId = userId;
   }

    @Column(name = "superheroe_id")
    Long superheroeId;

  public Long getSuperheroeId() {
        return superheroeId;
    }

    public void setSuperheroeId(Long superheroeId) {
        this.superheroeId = superheroeId;
    }

  public Long getId() {
    return id;
}

   public void setId(Long id) {
    this.id = id;
   }

  
    @ManyToOne
    @MapsId("userId")
    @JoinColumn(name = "user_id")
   @JsonIgnore
    User user;

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.userId = user.getId();
        this.user = user;
    }

    @ManyToOne
    @MapsId("superheroeId")
    @JoinColumn(name = "superheroe_id")
    @JsonIgnore
    Superheroe superheroe;

    public Superheroe getSuperheroe() {
        return superheroe;
    }

    public void setSuperheroe(Superheroe superheroe) {
        this.superheroeId = superheroe.getId();
        this.superheroe = superheroe;
    }

    @ManyToOne
    @MapsId("reactionId")
    @JoinColumn(name = "reaction_id")
    @JsonIgnore
    Reaction reaction;

    public Reaction getReaction() {
        return reaction;
    }

    public void setReaction(Reaction reaction) {
        this.reactionId = reaction.getId();
        this.reaction = reaction;
    }

}
