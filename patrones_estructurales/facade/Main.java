public class Main{
	public static void main(String[] args){
		DVDPlayer dvd=new DVDPlayer();
		Amplifier amp = new Amplifier();
		Projecto projecto= new Projecto();
		
		HomeTheaterFacade homeTheater= new HomeTheaterFacade(dvd,amp,projecto);

		homeTheater.watchMovie("Matrix");
	}
}
