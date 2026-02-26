
public class CuentaBancaria {

private double saldo;

//
// Methods
//


/**
 * Set the value of saldo
 * @param newVar the new value of saldo
 */
public void setSaldo (double newVar) {
saldo = newVar;
}

/**
 * Get the value of saldo
 * @return the value of saldo
 */
public double getSaldo () {
return saldo;
}

//
// Other methods
//

/**
 * @param        cantidad
 */
public CuentaBancaria(double cantidad)
{
	this.saldo= cantidad;
	System.out.println("Saldo inicial = $"+cantidad);
}


/**
 * @param        cantidad
 */
public void depositar(double cantidad)
{
	saldo += cantidad;
	System.out.println("deposito = "+cantidad);
}


/**
 * @param        double
 */
public void retirar(double cantidad)
{
	System.out.println("Retirando "+cantidad);
	if(this.saldo<1){
		System.out.println("Fondo insuficiente...");
	}else{
		this.saldo -=cantidad;
		System.out.println("retiro = "+cantidad);
	}
}


}
