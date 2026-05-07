class HomeTheaterFacade{
	private DVDPlayer dvd;
	private Amplifier amp;
	private Projecto projecto;

	HomeTheaterFacade(DVDPlayer dvd, Amplifier amp, Projecto projecto){
		this.dvd=dvd;
		this.amp=amp;
		this.projecto=projecto;
	}

	void watchMovie(String movie){
		System.out.println("Preparando cine en casa...");
		projecto.on();
		amp.on();
		amp.setVolume(5);
		dvd.on();
		dvd.play(movie);
	}
}
