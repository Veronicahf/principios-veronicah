
public class Main {
public static void main(String[] args)
{
	Producto p = new Producto("Cheetos",22,50);
	System.out.println("Nombre: "+p.getNombre());
	System.out.println("Precio: "+p.getPrecio());
	System.out.println("Stock: "+p.getStock());
	p.vender(2);
	System.out.println("Stock: "+p.getStock());
}


}
