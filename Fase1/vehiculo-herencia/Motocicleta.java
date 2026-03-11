
public class Motocicleta extends Vehiculo {

private int numAsientos;
//
// Methods
//


/**
 * Set the value of numAsientos
 * @param newVar the new value of numAsientos
 */
public void setNumAsientos (int newVar) {
numAsientos = newVar;
}

/**
 * Get the value of numAsientos
 * @return the value of numAsientos
 */
public int getNumAsientos () {
return numAsientos;
}

//
// Other methods
//

/**
 */
public void mostrarDatos()
{
	super.mostrarCaracteristicas();
	System.out.println("Numero de Asientos: "+numAsientos);
}


/**
 */
public void pruebaDelMotor()
{
	System.out.println("Pruebando el motor de la moto");
	super.encenderMotor();
	super.apagarMotor();
	super.funciona();
}


public Motocicleta(String marca, int precio, int llantas, int asientos)
{
	super(marca,precio,llantas);
	this.numAsientos=asientos;
}
}
