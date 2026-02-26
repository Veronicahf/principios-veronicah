
public class Main {
public static void main(String[] args)
{
CuentaBancaria cuenta = new CuentaBancaria(1000);
	cuenta.depositar(500);
	cuenta.retirar(1500);
	System.out.println("Saldo actual: "+cuenta.getSaldo());
	cuenta.retirar(100);
}


}
