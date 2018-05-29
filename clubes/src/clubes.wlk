class Club{
	//var calidad = null
	var property perfil = null
	var property socios = #{}
	var property actividades = #{}
	var property equipos = #{}
	var property actividadesSociales = #{}
	var property estaSancionado = false	
	var property gastoMensual = null
	
	method sancionar(actividadSocial){
		if (socios.size() < 500) actividadSocial.sancionar()
		else (estaSancionado = true) and equipos.forEach({equipo => equipo.cantSanciones() + 1})
	}
	
	method levantarSancion(actividadSocial){
		actividadSocial.levantarSancion()
	}
	
	method evaluacion(){
		return (perfil.evaluacionBruta(self) / self.socios().size())
	}
	
	method sociosDestacados(){
		return socios.filter({socio => self.esCapitan(socio) or self.esSocioOrganizador(socio)})
	}
	
	method sociosDestacadosYEstrellas(){
		return self.sociosDestacados().filter({socio => socio.esEstrella()})
	}
	
	method capitanes(){
		return self.equipos().filter({equipo => equipo.capitan()})
	}
	
	method sociosOrganizadores(){
		return self.actividadesSociales().filter({actividad => actividad.socioOrganizador()})
	}
	
	method esCapitan(_socio){
		return self.capitanes().contains(_socio)
	}
	
	method esSocioOrganizador(_socio){
		return self.sociosOrganizadores().contains(_socio)
	}
	
	method esPrestigioso(){
		return (self.equipos().any({equipo => equipo.esExperimentado()})) or
		(self.actividadSocialConAlMenos5ParticipantesEstrellas())
	}
	
	method actividadSocialConAlMenos5ParticipantesEstrellas(){
		return self.actividadesSociales().any({actividad => actividad.tieneAlMenos5ParticipantesEstrellas()})
	}
}

object tradicional{
	var property valorConfigurado
	
 	method valorConfigurado(valor){
 		valorConfigurado = valor
 	}
 	
 	method evaluacionBruta(club){
 		return (club.actividades().sum({actividad => actividad.evaluacion()}) - club.gastoMensual())
 	}
}

object comunitario{
	method evaluacionBruta(club){
 		return club.actividades().sum({actividad => actividad.evaluacion()})
 	}
}

object profesional{
 	var property valorConfigurado
 	
 	method valorConfigurado(valor){
 		valorConfigurado = valor
 	}
 	
 	method evaluacionBruta(club){
 		return (2 * club.actividades().sum({actividad => actividad.evaluacion()}) - 5 * club.gastoMensual())
 	}
}
class Actividad{
	var property cantActividades = null
	
	
}

class Equipo inherits Actividad{
	var property plantel = #{}
	var capitan 
	var property cantSanciones = 0
	var property campeonatosObtenidos = 0
	
	method esExperimentado(){
		return self.plantel().all({jugador => jugador.cantPartidos() > 10})
	}
	
	method capitan() = capitan
	
	method evaluacion(){
		return (self.puntosPorCampeonatos() + self.puntosPorPlantel() + self.puntosPorCapitanEstrella() - self.puntosDeSancion())
	}
	
	method puntosPorCampeonatos(){
		return campeonatosObtenidos * 5
	}
	
	method puntosPorPlantel(){
		return plantel.size() * 2
	}
	
	method puntosPorCapitanEstrella(){
		return if (capitan.esEstrella()) 5 else 0
	}
	method puntosDeSancion(){
		return cantSanciones * 20
	}
	
}

class EquipoDeFutbol inherits Equipo{
	override method evaluacion(){
		return	(super() + self.puntosPorJugadoresEstrellas())
	}
	
	method puntosPorJugadoresEstrellas(){
		return (plantel.count({jugador => jugador.esEstrella()}) * 5)
	}
	
	override method puntosDeSancion(){
		return cantSanciones * 30
	}
}

class ActividadSocial inherits Actividad{
	var socioOrganizador
	var property sociosActividad = #{}
	var property estaSuspendida = false
	var property valorEvaluacion = null
	
	method socioOrganizador() = socioOrganizador
	
	method sancionar(){
		estaSuspendida = true
	}
	
	method levantarSancion(){
		estaSuspendida = false
	}
	
	method evaluacion(){
		return 	if (self.estaSuspendida()) 0 else valorEvaluacion
	}
	
	method tieneAlMenos5ParticipantesEstrellas(){
		return self.sociosActividad().count({socio => socio.esEstrella()}) > 5
	}
}

class Socio{
	var property antiguedad
	var property club = null
	var property cantActividades = null
	
	method esEstrella(){
		return (antiguedad>20)
	}
	
}

class Jugador inherits Socio{
	var property valorPase
	var property cantPartidos
	
	override method esEstrella(){
		return (cantPartidos >= 50) 
	}
}
class JugadorProfesional inherits Jugador{
	override method esEstrella(){
		return (valorPase > club.perfil().valorConfigurado())
	}
}

class JugadorComunitario inherits Jugador{
	override method esEstrella(){
		return (self.cantActividades() >= 3)
	}	
}

class JugadorTradicional inherits Jugador{
	override method esEstrella(){
		return (valorPase > club.perfil().valorConfigurado()) or (self.cantActividades() >= 3)
	}
}

object transferir{
	var property equipoOrigen
	var property equipoDestino
		
	method transferencia(_jugador){
		/*if _jugador.club().sociosDestacados().contains(_jugador) return self.error("No se puede transferir")
		if equipoOrigen = equipoDestino return self.error("No se puede transferir")*/
		equipoOrigen.equipos().plantel().remove(_jugador)
		and equipoOrigen.actividadesSociales().sociosActividad().remove(_jugador)
		and equipoDestino.plantel().add(_jugador)
		and equipoOrigen.socios().remove(_jugador)
		and equipoDestino.socios().add(_jugador)
		and _jugador.cantPartidos() == 0
	}
}