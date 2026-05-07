package com.vero.superheroes.controllers;
import java.util.Map;
import java.util.HashMap;
import java.util.stream.Collectors;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.vero.superheroes.models.Comment;
import com.vero.superheroes.models.Superheroe;
import com.vero.superheroes.models.User;
import com.vero.superheroes.payload.request.CommentRequest;
import com.vero.superheroes.payload.response.MessageResponse;
import com.vero.superheroes.repository.CommentRepository;
import com.vero.superheroes.repository.SuperheroeRepository;
import com.vero.superheroes.repository.UserRepository;

import jakarta.validation.Valid;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/comments")
public class CommentController {

    @Autowired
    private CommentRepository commentRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private SuperheroeRepository superheroeRepository;

    @PostMapping("/create")
    public ResponseEntity<?> createComment(@Valid @RequestBody CommentRequest commentRequest) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String username = authentication.getName();

        Optional<User> userOpt = userRepository.findByUsername(username);
        if (userOpt.isEmpty()) {
            return ResponseEntity.badRequest().body(new MessageResponse("Error: Usuario no encontrado."));
        }
        User user = userOpt.get();

        Optional<Superheroe> superheroeOpt = superheroeRepository.findById(commentRequest.getSuperheroeId());
        if (superheroeOpt.isEmpty()) {
            return ResponseEntity.badRequest().body(new MessageResponse("Error: Superhéroe no encontrado."));
        }
        Superheroe superheroe = superheroeOpt.get();

        Comment comment = new Comment();
        comment.setContent(commentRequest.getContent());
        comment.setUser(user);
        comment.setSuperheroe(superheroe);

        commentRepository.save(comment);

        return ResponseEntity.ok(new MessageResponse("Comentario creado exitosamente!"));
    }

    @GetMapping("/superheroe/{superheroeId}")
    public ResponseEntity<List<Map<String, Object>>> getCommentsBySuperheroe(@PathVariable Long superheroeId) {
        
        // Obtienes la lista normal de tu base de datos
        List<Comment> comments = commentRepository.findBySuperheroeId(superheroeId); 
        
        // Transformamos cada comentario a un "Mapa" limpio y seguro
        List<Map<String, Object>> response = comments.stream().map(c -> {
            Map<String, Object> map = new HashMap<>();
            map.put("id", c.getId());
            map.put("content", c.getContent()); // O el getter que uses para el texto del comentario
            map.put("createdAt", c.getCreatedAt()); // Omitir si no tienes fechas
            
            // ¡Aquí está la clave! Extraemos solo lo necesario del usuario
            if (c.getUser() != null) {
                Map<String, Object> userMap = new HashMap<>();
                userMap.put("id", c.getUser().getId());
                userMap.put("username", c.getUser().getUsername()); // nombre
                map.put("user", userMap);
            }
            
            return map;
        }).collect(Collectors.toList());
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/superheroe/{superheroeId}/count")
    public long countCommentsBySuperheroe(@PathVariable Long superheroeId) {
        return commentRepository.countBySuperheroeId(superheroeId);
    }
}