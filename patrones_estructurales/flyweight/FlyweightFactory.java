import java.util.HashMap;
import java.util.Map;

public class FlyweigthFactory{
	private Map<String, Flyweigth> pool=new HashMap<>();
	@param fuente
	@param tamaño
	@param color
	@return

	public Flyweigth obtenerFlyweight(String fuente,int tamaño, String color){
		String clave=generarClave(fuente,tamaño, color);
		if(!pool.containsKey(clave)){
			System.out.println("[NUEVO] creando Flyweigth "+ clave);
			pool.put(clave,new ConcreteFlyweigth(fuente, tamaño,color));
		}else{
			System.out.println("[REUTILIZADO] Usando Flyweight del pool: "+clave);
		}

		return pool.get(clave);
	}
	private String generarClave(String fuente,int tamaño, String color){
		return fuente+ "_"+tamaño+"_"+ color;
	}

	public void mostrarEstadoPool(){
		System.out.println("\n ===Estado del POOL ===");
		System.out.println("Objetos FlyWeight en el pool: "+ pool.size());
		for(String clave:pool.keySet()){
			System.out.println("  -   " + clave);
		}
		System.out.println("=============================");
	}

	public int obtenerTamañoPool(){
		return pool.size();
	}
}
