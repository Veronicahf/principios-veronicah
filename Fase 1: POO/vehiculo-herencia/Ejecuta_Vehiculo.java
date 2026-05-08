public class Ejecuta_Vehiculo {

public static void main(String[] args)
{
	Automovil v1 = new Automovil("volco 550",120,4,5,4);
	v1.mostrarDatos();
	v1.pruebaDelMotor();

	System.out.println();	
	Motocicleta m1 = new Motocicleta("italika",120,2,2);
	m1.mostrarDatos();
	m1.pruebaDelMotor();

	System.out.println();
	Autobus b1 = new Autobus("Mercedez",300,8,42,2,2);
	b1.mostrarDatos();
	b1.pruebaDelMotor();

	System.out.println();
	Autobus b2 = new Autobus("Mercedez smart",250,6,25,1,1);
	b2.mostrarDatos();
	b2.pruebaDelMotor();
}


}
