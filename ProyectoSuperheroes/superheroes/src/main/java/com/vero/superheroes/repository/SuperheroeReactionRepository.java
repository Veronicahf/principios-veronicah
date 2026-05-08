package com.vero.superheroes.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.vero.superheroes.models.SuperheroeReaction;

@Repository
public interface SuperheroeReactionRepository extends JpaRepository<SuperheroeReaction, Long> {
    // Contar todas las reacciones para un superhéroe específico.
    long countBySuperheroeId(Long superheroeId);

    // Encontrar todas las reacciones para un superhéroe específico.
    // Esto nos permitirá ver qué usuarios reaccionaron.
    List<SuperheroeReaction> findBySuperheroeId(Long superheroeId);

    // Encontrar la reacción exacta de un usuario sobre un superhéroe.
    Optional<SuperheroeReaction> findByUserIdAndSuperheroeId(Long userId, Long superheroeId);

    // Eliminar la reacción exacta de un usuario sobre un superhéroe.
    void deleteByUserIdAndSuperheroeId(Long userId, Long superheroeId);

    // Contar cuántas reacciones de un tipo específico tiene un superhéroe.
    // Por ejemplo, cuántos "likes" tiene un superhéroe.
    long countBySuperheroeIdAndReactionId(Long superheroeId, Long reactionId);
}

