-- Script para insertar datos iniciales de reacciones y comentarios
-- Ejecutar en Aiven PostgreSQL después de crear las tablas

-- Insertar tipos de reacciones disponibles
INSERT INTO reactions (id, description) VALUES
(1, 'REACTION_LIKE'),
(2, 'REACTION_LOVE'),
(3, 'REACTION_HATE'),
(4, 'REACTION_SAD'),
(5, 'REACTION_ANGRY')
ON CONFLICT (id) DO NOTHING;

-- Opcional: Insertar algunas reacciones de ejemplo (si tienes superhéroes y usuarios)
-- Asegúrate de tener usuarios y superhéroes creados primero
-- INSERT INTO tweet_reactions (user_id, superheroe_id, reaction_id) VALUES
-- (1, 1, 1),  -- Usuario 1 le da Like al superhéroe 1
-- (2, 1, 2),  -- Usuario 2 le da Love al superhéroe 1
-- (3, 1, 1),  -- Usuario 3 le da Like al superhéroe 1
-- (1, 2, 5),  -- Usuario 1 le da Angry al superhéroe 2
-- ON CONFLICT DO NOTHING;

-- Verificar que las reacciones se insertaron correctamente
SELECT * FROM reactions;
