package com.vero.superheroes.payload.response;

import com.vero.superheroes.models.Superheroe;

public class SuperheroeResponseDTO {
  private Long id;
  private String nombre;
  private String habilidades;
  private String debilidades;
  private String enemigos;
  private String urlPhoto;
  private UserResponseDTO postedBy;

  public SuperheroeResponseDTO(Superheroe superheroe) {
    this.id = superheroe.getId();
    this.nombre = superheroe.getNombre();
    this.habilidades = superheroe.getHabilidades();
    this.debilidades = superheroe.getDebilidades();
    this.enemigos = superheroe.getEnemigos();
    this.urlPhoto = superheroe.getUrlPhoto();
    this.postedBy = new UserResponseDTO(superheroe.getPostedBy());
  }

  public Long getId() {
    return id;
  }

  public void setId(Long id) {
    this.id = id;
  }

  public String getNombre() {
    return nombre;
  }

  public void setNombre(String nombre) {
    this.nombre = nombre;
  }

  public String getHabilidades() {
    return habilidades;
  }

  public void setHabilidades(String habilidades) {
    this.habilidades = habilidades;
  }

  public String getDebilidades() {
    return debilidades;
  }

  public void setDebilidades(String debilidades) {
    this.debilidades = debilidades;
  }

  public String getEnemigos() {
    return enemigos;
  }

  public void setEnemigos(String enemigos) {
    this.enemigos = enemigos;
  }

  public String getUrlPhoto() {
    return urlPhoto;
  }

  public void setUrlPhoto(String urlPhoto) {
    this.urlPhoto = urlPhoto;
  }

  public UserResponseDTO getPostedBy() {
    return postedBy;
  }

  public void setPostedBy(UserResponseDTO postedBy) {
    this.postedBy = postedBy;
  }
}
