
public class Avion {

public String aerolinea;
public String capacidad;
protected String velocidad;
private String cantidadMotores;
//
// Methods
//


/**
 * Set the value of aerolinea
 * @param newVar the new value of aerolinea
 */
public void setAerolinea (String newVar) {
aerolinea = newVar;
}

/**
 * Get the value of aerolinea
 * @return the value of aerolinea
 */
public String getAerolinea () {
return aerolinea;
}

/**
 * Set the value of capacidad
 * @param newVar the new value of capacidad
 */
public void setCapacidad (String newVar) {
capacidad = newVar;
}

/**
 * Get the value of capacidad
 * @return the value of capacidad
 */
public String getCapacidad () {
return capacidad;
}

/**
 * Set the value of velocidad
 * @param newVar the new value of velocidad
 */
public void setVelocidad (String newVar) {
velocidad = newVar;
}

/**
 * Get the value of velocidad
 * @return the value of velocidad
 */
public String getVelocidad () {
return velocidad;
}

/**
 * Set the value of cantidadMotores
 * @param newVar the new value of cantidadMotores
 */
public void setCantidadMotores (String newVar) {
cantidadMotores = newVar;
}

/**
 * Get the value of cantidadMotores
 * @return the value of cantidadMotores
 */
public String getCantidadMotores () {
return cantidadMotores;
}

//
// Other methods
//

/**
 * @param        aerolinea1
 * @param        cantidadMotores1
 * @param        velocidad1
 * @param        capacidad1
 */
public Avion(String aerolinea1, String cantidadMotores1, String velocidad1, String capacidad1)
{
this.aerolinea=aerolinea1;
	this.cantidadMotores=cantidadMotores1;
	this.velocidad=velocidad1;
	this.capacidad=capacidad1;
	System.out.println("Construyo un avion");
}


/**
 */
public void acelerar()
{
System.out.println("El avion acelero");
}


/**
 */
public void elevarse()
{
	System.out.println("El avion se elevoo");
}

}
