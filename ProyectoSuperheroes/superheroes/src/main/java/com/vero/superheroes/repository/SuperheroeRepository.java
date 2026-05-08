package com.vero.superheroes.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import com.vero.superheroes.models.Superheroe;

@Repository
public interface SuperheroeRepository extends JpaRepository<Superheroe, Long> {
}
