/* View de avaliações das lavanderias */
CREATE VIEW vw_avaliacoes AS
SELECT 
    l.nome AS lavanderia,
    u.nome AS usuario,
    a.nota,
    a.comentario,
    a.data
FROM avaliacao a
JOIN usuario u ON u.usuario_id = a.fk_usuario_id
JOIN lavanderia l ON l.lavanderia_id = a.fk_lavanderia_id;

SELECT * FROM vw_avaliacoes;

/* View de média de avaliações das lavanderias */
CREATE VIEW vw_media_lavanderia AS
SELECT 
    l.lavanderia_id,
    l.nome,
    ROUND(AVG(a.nota),1) AS media_avaliacao
FROM lavanderia l
LEFT JOIN avaliacao a 
    ON a.fk_lavanderia_id = l.lavanderia_id
GROUP BY l.lavanderia_id, l.nome;

SELECT * FROM vw_media_lavanderia ORDER BY media_avaliacao DESC;

/* View para mostrar endereço do usuário no perfil */
CREATE VIEW vw_usuario_endereco_perfil AS
SELECT 
    u.usuario_id,
    u.nome,
    CONCAT(
		COALESCE(e.logradouro, ''),', ',
		COALESCE(e.numero, ''),' - ',
        COALESCE(e.bairro, ''),', ',
        COALESCE(e.cidade, ''),' - ',
        COALESCE(e.uf, ''), ' - CEP: ',
        COALESCE(e.cep, ''),
		COALESCE(e.complemento, '')
        ) AS endereco_completo
FROM usuario u
JOIN endereco e 
    ON e.endereco_PK = u.fk_endereco;
    
/* View para mostrar pedidos completo(histórico) */
CREATE VIEW vw_pedido_completo AS
SELECT 
    p.pedido_id,
    u.nome AS usuario,
    l.nome AS lavanderia,
    p.valor_total,
    p.taxa_entrega,
    p.tempo_estimado,
    s.descricao AS status,
    p.data
FROM pedido p
JOIN usuario u ON u.usuario_id = p.fk_usuario_id
JOIN lavanderia l ON l.lavanderia_id = p.fk_lavanderia_id
JOIN status s ON s.status_id = p.fk_status_id;

SELECT * FROM vw_pedido_completo;

/* View para mostrar pagamento detalhado(histórico) */
CREATE VIEW vw_pagamento_detalhado AS
SELECT 
    op.ordem_pagamento_id,
    op.tipo_pagamento,
    op.valor,
    op.status,
    p.pedido_id,
    
    pc.tipo AS tipo_cartao,
    px.status AS status_pix
    
FROM ordem_pagamento op
LEFT JOIN pagamento_cartao pc 
    ON pc.fk_ordem_pagamento_id = op.ordem_pagamento_id
LEFT JOIN pix px 
    ON px.fk_ordem_pagamento_id = op.ordem_pagamento_id
JOIN pedido p 
    ON p.pedido_id = op.fk_pedido_id;
    
/* View para mostrar o cesto e roupas */
CREATE VIEW vw_cesto_roupas AS
SELECT 
    c.cesto_id,
    r.nome_peca,
    re.fk_roupas_id,
    r.quantidade
FROM cesto c
JOIN recebe re ON re.fk_cesto_id = c.cesto_id
JOIN roupas r ON r.id = re.fk_roupas_id;

/* View para mostrar lavanderias favoritadas(filtro) */
CREATE VIEW vw_favoritos_usuario AS
SELECT 
    u.nome AS usuario,
    l.nome AS lavanderia
FROM favoritos f
JOIN usuario u ON u.usuario_id = f.fk_usuario_id
JOIN lavanderia l ON l.lavanderia_id = f.fk_lavanderia_id;