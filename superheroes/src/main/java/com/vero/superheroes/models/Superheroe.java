package com.vero.superheroes.models;

import com.fasterxml.jackson.annotation.JsonIgnore;
import java.util.Set;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;

@Entity
@Table(name = "superheroes")
public class Superheroe {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank
    private String nombre;

    private String habilidades;
    private String debilidades;
    private String enemigos;

    @Column(name = "url_photo")
    private String urlPhoto;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "posted_by", referencedColumnName = "id")
    private User postedBy;

    @OneToMany(mappedBy = "superheroe")
    @JsonIgnore
    Set<SuperheroeReaction> likes;

    public Superheroe() {}

    public Superheroe(String nombre, String habilidades, String debilidades, String enemigos, String urlPhoto) {
        this.nombre = nombre;
        this.habilidades = habilidades;
        this.debilidades = debilidades;
        this.enemigos = enemigos;
        this.urlPhoto = urlPhoto;
    }

    // Getters y Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    public String getHabilidades() { return habilidades; }
    public void setHabilidades(String habilidades) { this.habilidades = habilidades; }
    public String getDebilidades() { return debilidades; }
    public void setDebilidades(String debilidades) { this.debilidades = debilidades; }
    public String getEnemigos() { return enemigos; }
    public void setEnemigos(String enemigos) { this.enemigos = enemigos; }
    public String getUrlPhoto() { return urlPhoto; }
    public void setUrlPhoto(String urlPhoto) { this.urlPhoto = urlPhoto; }

    public User getPostedBy() {
        return postedBy;
    }

    public void setPostedBy(User postedBy) {
        this.postedBy = postedBy;
    }

    public Set<SuperheroeReaction> getLikes() {
        return likes;
    }

    public void setLikes(Set<SuperheroeReaction> likes) {
        this.likes = likes;
    }
}
