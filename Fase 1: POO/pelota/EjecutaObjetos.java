
public class EjecutaObjetos {
public static void main(String[] args)
{ 
	Pelota p1 = new Pelota("Circular", "Amarilla", "Plastico","Infantil");
	p1.botar();
	p1.desinflar();
	Pelota p2 = new Pelota("Circular", "rojo", "pochi", "Gym");
	p2.botar();
	p2.desinflar();
}


}
