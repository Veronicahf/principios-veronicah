package com.vero.demoVero.repository;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.vero.demoVero.models.Tweet;

@Repository
public interface TweetRepository extends JpaRepository<Tweet, Long> {

}

