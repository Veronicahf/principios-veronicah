package com.vero.superheroes.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.vero.superheroes.models.SuperheroeReaction;

@Repository
public interface SuperheroeReactionRepository extends JpaRepository<SuperheroeReaction, Long> {

}

