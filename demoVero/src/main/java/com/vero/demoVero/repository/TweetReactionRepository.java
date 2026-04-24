package com.vero.demoVero.repository;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.vero.demoVero.models.TweetReaction;

@Repository
public interface TweetReactionRepository extends JpaRepository<TweetReaction, Long> {

}

