-- =========================================================
-- VIEWS
-- =========================================================

CREATE VIEW vw_avaliacoes AS
SELECT
    l.nome AS lavanderia,
    u.nome AS usuario,
    a.nota,
    a.comentario,
    a.data
FROM avaliacao a
INNER JOIN usuario u
    ON u.usuario_id = a.fk_usuario_id
INNER JOIN lavanderia l
    ON l.lavanderia_id = a.fk_lavanderia_id;

CREATE VIEW vw_media_lavanderia AS
SELECT
    l.lavanderia_id,
    l.nome,
    ROUND(AVG(a.nota),1) AS media_avaliacao
FROM lavanderia l
LEFT JOIN avaliacao a
    ON a.fk_lavanderia_id = l.lavanderia_id
GROUP BY l.lavanderia_id, l.nome;

CREATE VIEW vw_usuario_endereco_perfil AS
SELECT
    u.usuario_id,
    u.nome,

    CONCAT(
        e.logradouro, ', ',
        e.numero, ' - ',
        e.bairro, ', ',
        e.cidade, ' - ',
        e.uf, ' CEP: ',
        e.cep
    ) AS endereco_completo

FROM usuario u
INNER JOIN endereco e
    ON e.endereco_id = u.fk_endereco;

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
INNER JOIN usuario u
    ON u.usuario_id = p.fk_usuario_id
INNER JOIN lavanderia l
    ON l.lavanderia_id = p.fk_lavanderia_id
INNER JOIN status s
    ON s.status_id = p.fk_status_id;

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

INNER JOIN pedido p
    ON p.pedido_id = op.fk_pedido_id;

CREATE VIEW vw_cesto_roupas AS
SELECT
    c.cesto_id,
    r.nome_peca,
    cr.quantidade
FROM cesto c
INNER JOIN cesto_roupa cr
    ON cr.fk_cesto_id = c.cesto_id
INNER JOIN roupas r
    ON r.id = cr.fk_roupas_id;

CREATE VIEW vw_favoritos_usuario AS
SELECT
    u.nome AS usuario,
    l.nome AS lavanderia
FROM favoritos f
INNER JOIN usuario u
    ON u.usuario_id = f.fk_usuario_id
INNER JOIN lavanderia l
    ON l.lavanderia_id = f.fk_lavanderia_id;

CREATE VIEW vw_lavanderias_completas AS
SELECT
    l.lavanderia_id,
    l.nome,
    l.descricao,
    l.preco_padrao_lavagem,
    l.preco_padrao_secagem,
    l.logo,
    l.telefone,

    e.cidade,
    e.uf,
    e.bairro,
    e.logradouro,
    e.numero

FROM lavanderia l

INNER JOIN endereco_lavanderia e
    ON l.fk_endereco_lavanderia =
       e.endereco_lavanderia_id;

CREATE VIEW vw_lavanderias_preco AS
SELECT
    lavanderia_id,
    nome,
    preco_padrao_lavagem,
    preco_padrao_secagem,

    (
        preco_padrao_lavagem +
        preco_padrao_secagem
    ) / 2 AS preco_medio

FROM lavanderia;

CREATE VIEW vw_lavanderias_populares AS
SELECT
    l.lavanderia_id,
    l.nome,

    COUNT(p.pedido_id) AS total_pedidos

FROM lavanderia l

LEFT JOIN pedido p
    ON p.fk_lavanderia_id = l.lavanderia_id

GROUP BY l.lavanderia_id, l.nome

ORDER BY total_pedidos DESC;

CREATE OR REPLACE VIEW vw_home_usuario_pedidos AS
SELECT
    p.pedido_id,

    u.usuario_id,
    u.nome AS nome_usuario,

    s.descricao AS status_pedido,

    p.valor_total,

    p.tempo_estimado,

    p.data AS data_pedido,

    COUNT(c.cesto_id) AS quantidade_cestos

FROM pedido p

INNER JOIN usuario u
    ON u.usuario_id = p.fk_usuario_id

INNER JOIN status s
    ON s.status_id = p.fk_status_id

LEFT JOIN cesto c
    ON c.fk_pedido_id = p.pedido_id

GROUP BY
    p.pedido_id,
    u.usuario_id,
    u.nome,
    s.descricao,
    p.valor_total,
    p.tempo_estimado,
    p.data;