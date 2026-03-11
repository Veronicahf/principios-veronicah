
public class Vehiculo {

protected int precioDia;
protected String marcaModelo;
protected int numllantas;
//
// Methods
//


/**
 * Set the value of precioDia
 * @param newVar the new value of precioDia
 */
public void setPrecioDia (int newVar) {
precioDia = newVar;
}

/**
 * Get the value of precioDia
 * @return the value of precioDia
 */
public int getPrecioDia () {
return precioDia;
}

/**
 * Set the value of marcaModelo
 * @param newVar the new value of marcaModelo
 */
public void setMarcaModelo (String newVar) {
marcaModelo = newVar;
}

/**
 * Get the value of marcaModelo
 * @return the value of marcaModelo
 */
public String getMarcaModelo () {
return marcaModelo;
}

/**
 * Set the value of numllantas
 * @param newVar the new value of numllantas
 */
public void setNumllantas (int newVar) {
numllantas = newVar;
}

/**
 * Get the value of numllantas
 * @return the value of numllantas
 */
public int getNumllantas () {
return numllantas;
}

public Vehiculo(String marca, int precio,int llantas)
{
	this.marcaModelo=marca;
	this.precioDia=precio;
	this.numllantas=llantas;
}
//
// Other methods
//

/**
 */
public void mostrarCaracteristicas()
{
	System.out.println("Caracteristicas:\nPrecio: "+precioDia+"\nMarca: "+marcaModelo+"\nNumero de llantas: "+numllantas);

}


/**
 */
public void encenderMotor()
{
	System.out.println("El Motor Esta  encendido");
}


/**
 */
public void apagarMotor()
{
	System.out.println("Motor apagado");
}


/**
 */
public void funciona()
{
 	System.out.println("Funcionando...");
}


}
