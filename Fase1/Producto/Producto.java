
public class Producto {

private String nombre;
private double precio;
private int stock;
public Producto(String nombre, double precio, int stock)
{
	this.nombre=nombre;
	this.precio=precio;
	this.stock=stock;
}


/**
 * @return       String
 */
public String getNombre()
{
	return nombre;
}


/**
 * @return       double
 */
public double getPrecio()
{
	return precio;
}


/**
 * @param        precio
 */
public void setPrecio(double precio1)
{
	precio=precio1;
}


/**
 * @return       int
 */
public int getStock()
{
	return stock;
}


/**
 * @param        cantidad
 */
public void vender(int cantidad)
{
	if(cantidad>stock){
		System.out.println("No hay stock suficiente");
	}else{
		stock-=cantidad;
		System.out.println("Venta realizada");
	}
}


}
