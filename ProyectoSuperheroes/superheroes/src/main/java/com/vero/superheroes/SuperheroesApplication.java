package com.vero.superheroes;

import java.util.List;

import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

import com.vero.superheroes.models.ERole;
import com.vero.superheroes.models.EReaction;
import com.vero.superheroes.models.Reaction;
import com.vero.superheroes.models.Role;
import com.vero.superheroes.repository.RoleRepository;
import com.vero.superheroes.repository.ReactionRepository;

@SpringBootApplication
public class SuperheroesApplication {

	public static void main(String[] args) {
		SpringApplication.run(SuperheroesApplication.class, args);
	}

	@Bean
	CommandLineRunner initData(RoleRepository roleRepository, ReactionRepository reactionRepository) {
		return args -> {
			List<ERole> defaultRoles = List.of(ERole.ROLE_USER, ERole.ROLE_MODERATOR, ERole.ROLE_ADMIN);
			for (ERole roleName : defaultRoles) {
				roleRepository.findByName(roleName).orElseGet(() -> roleRepository.save(new Role(roleName)));
			}

			List<EReaction> defaultReactions = List.of(
				EReaction.REACTION_LIKE,
				EReaction.REACTION_LOVE,
				EReaction.REACTION_HATE,
				EReaction.REACTION_SAD,
				EReaction.REACTION_ANGRY
			);
			for (EReaction reactionName : defaultReactions) {
				reactionRepository.findAll().stream()
					.filter(reaction -> reaction.getDescription() == reactionName)
					.findFirst()
					.orElseGet(() -> reactionRepository.save(new Reaction(reactionName)));
			}
		};
	}

}
