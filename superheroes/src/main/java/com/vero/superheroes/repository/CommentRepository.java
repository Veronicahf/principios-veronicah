package com.vero.superheroes.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.vero.superheroes.models.Comment;

@Repository
public interface CommentRepository extends JpaRepository<Comment, Long> {

    // Encontrar todos los comentarios para un superhéroe específico.
    List<Comment> findBySuperheroeId(Long superheroeId);

    // Contar todos los comentarios para un superhéroe específico.
    long countBySuperheroeId(Long superheroeId);
}