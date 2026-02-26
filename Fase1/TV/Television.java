
public class Television {

public String forma;
public String calidadVideo;
protected String marca;
private String tama_o;

public void setForma (String newVar) {
forma = newVar;
}

public String getForma () {
return forma;
}

public void setCalidadVideo (String newVar) {
calidadVideo = newVar;
}

public String getCalidadVideo () {
return calidadVideo;
}

public void setMarca (String newVar) {
marca = newVar;
}

public String getMarca () {
return marca;
}

public void setTama_o (String newVar) {
tama_o = newVar;
}

public String getTama_o () {
return tama_o;
}

//
// Other methods
//

/**
 * @param        forma1
 * @param        tama_o1
 * @param        calidadVideo
 * @param        marca
 */
public Television(String forma1, String tama_o1, String calidadVideo, String marca)
{
	this.forma = forma1;
	this.tama_o = tama_o1;
	this.calidadVideo = calidadVideo;
	this.marca = marca;
	System.out.println("Construyo una television");
}


public void apagada()
{
	System.out.println("Television apagada");
}


/**
 */
public void prendida()
{
	System.out.println("Television encendida");
}


}
