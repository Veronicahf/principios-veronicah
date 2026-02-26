
public class Persona {

private String nombre;
private int edad;

public void setNombre (String newVar) {
nombre = newVar;
}

public String getNombre () {
return nombre;
}

public void setEdad (int newVar) {
edad = newVar;
}

public int getEdad () {
return edad;
}

public Persona(String nombre, int edad){
	this.nombre = nombre;
	this.edad = edad;
}

public void saludar(){
	System.out.println("Hello "+ this.nombre);
}

}
