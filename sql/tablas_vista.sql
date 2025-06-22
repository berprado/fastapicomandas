--
-- Set default database
--
USE adminerp_copy;

--
-- Create table `alm_categoria`
--
CREATE TABLE alm_categoria
  (
    id                INT(11)      NOT NULL AUTO_INCREMENT,
    nombre            VARCHAR(255) NOT NULL,
    descripcion       VARCHAR(255) DEFAULT NULL,
    p_grupo_categoria INT(11)      NOT NULL COMMENT 'se define datos como: bebidas, bocaditos, prendas, souvenirs',
    desde             INT(11)      DEFAULT NULL,
    hasta             INT(11)      DEFAULT NULL,
    correlativo       INT(11)      DEFAULT NULL,
    usuario_reg       VARCHAR(255) NOT NULL,
    fecha_reg         DATE         DEFAULT NULL,
    fecha_mod         DATE         DEFAULT NULL,
    estado            VARCHAR(3)   NOT NULL,
    PRIMARY KEY (id)
  )
ENGINE = INNODB,
AUTO_INCREMENT = 23,
AVG_ROW_LENGTH = 819,
CHARACTER SET latin1,
COLLATE latin1_swedish_ci,
COMMENT = 'INFORMACION SOBRE LAS CATEGORIAS DE PRODUCTOS EXISTENTES',
ROW_FORMAT = COMPACT;

--
-- Create table `bar_combo_coctel`
--
CREATE TABLE bar_combo_coctel
  (
    id           INT(11)      NOT NULL AUTO_INCREMENT,
    nombre       VARCHAR(255) NOT NULL,
    codigo       VARCHAR(255) NOT NULL,
    descripcion  VARCHAR(255) DEFAULT NULL,
    id_categoria INT(11)      DEFAULT NULL,
    id_barra     INT(11)      DEFAULT NULL,
    usuario_reg  VARCHAR(255) NOT NULL,
    fecha_reg    DATE         DEFAULT NULL,
    fecha_mod    DATE         DEFAULT NULL,
    estado       VARCHAR(3)   NOT NULL,
    PRIMARY KEY (id)
  )
ENGINE = INNODB,
AUTO_INCREMENT = 390,
AVG_ROW_LENGTH = 168,
CHARACTER SET latin1,
COLLATE latin1_swedish_ci,
COMMENT = 'Almacena información sobre los combos o cócteles disponibles en el bar.',
ROW_FORMAT = COMPACT;

--
-- Create foreign key
--
ALTER TABLE bar_combo_coctel
ADD CONSTRAINT fk_bar_combo_coctel_bar_barra FOREIGN KEY (id_barra)
REFERENCES bar_barra (id);

--
-- Create foreign key
--
ALTER TABLE bar_combo_coctel
ADD CONSTRAINT fk_bar_combo_coctel_alm_categoria FOREIGN KEY (id_categoria)
REFERENCES alm_categoria (id);

DELIMITER $$

--
-- Create trigger `trg_update_combo_to_siat`
--
CREATE
DEFINER = 'root'@'localhost'
TRIGGER trg_update_combo_to_siat
AFTER UPDATE
ON bar_combo_coctel
FOR EACH ROW
BEGIN
IF NEW.estado = 'HAB'
THEN
  INSERT INTO adminerp_copy.productos_siat
        (
          codigo,
          nombre,
          unidad_medida,
          tipo_origen,
          id_origen
        )
  VALUES
      (
        NEW.codigo, NEW.nombre, SUBSTRING_INDEX (NEW.descripcion, ' ', 1), 'combo', NEW.id
      )
  ON DUPLICATE KEY UPDATE
  nombre = VALUES(
    nombre),
  unidad_medida = VALUES(
    unidad_medida),
  tipo_origen = 'combo',
  id_origen = NEW.id,
  fecha_actualizacion = CURRENT_TIMESTAMP;
ELSE
  DELETE
  FROM
          adminerp_copy.productos_siat
  WHERE
          tipo_origen = 'combo'
          AND id_origen = OLD.id;
END IF;
END
$$

--
-- Create trigger `trg_insert_combo_to_siat`
--
CREATE
DEFINER = 'root'@'localhost'
TRIGGER trg_insert_combo_to_siat
AFTER INSERT
ON bar_combo_coctel
FOR EACH ROW
BEGIN
IF NEW.estado = 'HAB'
THEN
  INSERT INTO adminerp_copy.productos_siat
        (
          codigo,
          nombre,
          unidad_medida,
          tipo_origen,
          id_origen
        )
  VALUES
      (
        NEW.codigo, NEW.nombre, SUBSTRING_INDEX (NEW.descripcion, ' ', 1), 'combo', NEW.id
      )
  ON DUPLICATE KEY UPDATE
  nombre = VALUES(
    nombre),
  unidad_medida = VALUES(
    unidad_medida),
  tipo_origen = 'combo',
  id_origen = NEW.id,
  fecha_actualizacion = CURRENT_TIMESTAMP;
END IF;
END
$$

DELIMITER ;

--
-- Create table `alm_producto`
--
CREATE TABLE alm_producto
  (
    id                      INT(11)        NOT NULL AUTO_INCREMENT,
    nombre                  VARCHAR(255)   NOT NULL,
    descripcion             VARCHAR(255)   DEFAULT NULL,
    correlativo             INT(11)        NOT NULL,
    id_categoria            INT(11)        NOT NULL,
    id_proveedor            INT(11)        DEFAULT NULL,
    codigo                  VARCHAR(255)   DEFAULT NULL,
    medida                  DECIMAL(10, 2) NOT NULL,
    p_unidad_medida         INT(11)        NOT NULL,
    cantidad_detalle        DECIMAL(10, 2) DEFAULT NULL,
    p_unidad_medida_detalle INT(11)        DEFAULT NULL,
    minimo_stock            DECIMAL(10, 2) DEFAULT NULL,
    maximo_stock            DECIMAL(10, 2) DEFAULT NULL,
    minimo_stock_barra      DECIMAL(10, 2) DEFAULT NULL,
    maximo_stock_barra      DECIMAL(10, 2) DEFAULT NULL,
    file                    MEDIUMBLOB     DEFAULT NULL,
    filename                VARCHAR(255)   DEFAULT NULL,
    ind_permite_comandar    INT(11)        DEFAULT NULL,
    id_barra                INT(11)        DEFAULT NULL,
    usuario_reg             VARCHAR(255)   NOT NULL,
    fecha_reg               DATE           DEFAULT NULL,
    fecha_mod               DATE           DEFAULT NULL,
    estado                  VARCHAR(3)     NOT NULL,
    PRIMARY KEY (id)
  )
ENGINE = INNODB,
AUTO_INCREMENT = 481,
AVG_ROW_LENGTH = 205,
CHARACTER SET latin1,
COLLATE latin1_swedish_ci,
ROW_FORMAT = COMPACT;

--
-- Create index `fk_alm_producto_alm_proveedor1_idx` on table `alm_producto`
--
ALTER TABLE alm_producto
ADD INDEX fk_alm_producto_alm_proveedor1_idx (id_proveedor);

--
-- Create index `fk_producto_categoria_idx` on table `alm_producto`
--
ALTER TABLE alm_producto
ADD INDEX fk_producto_categoria_idx (id_categoria);

--
-- Create foreign key
--
ALTER TABLE alm_producto
ADD CONSTRAINT fk_producto_categoria FOREIGN KEY (id_categoria)
REFERENCES alm_categoria (id) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Create foreign key
--
ALTER TABLE alm_producto
ADD CONSTRAINT fk_alm_producto_alm_proveedor1 FOREIGN KEY (id_proveedor)
REFERENCES alm_proveedor (id) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Create foreign key
--
ALTER TABLE alm_producto
ADD CONSTRAINT fk_alm_producto_bar_barra1 FOREIGN KEY (id_barra)
REFERENCES bar_barra (id);

DELIMITER $$

--
-- Create trigger `trg_update_producto_to_siat`
--
CREATE
DEFINER = 'root'@'localhost'
TRIGGER trg_update_producto_to_siat
AFTER UPDATE
ON alm_producto
FOR EACH ROW
BEGIN
IF NEW.estado = 'HAB'
  AND
  NEW.ind_permite_comandar = 70
THEN
  INSERT INTO adminerp_copy.productos_siat
        (
          codigo,
          nombre,
          unidad_medida,
          tipo_origen,
          id_origen
        )
  VALUES
      (
        NEW.codigo, NEW.nombre, SUBSTRING_INDEX (NEW.descripcion, ' ', 1), 'producto', NEW.id
      )
  ON DUPLICATE KEY UPDATE
  nombre = VALUES(
    nombre),
  unidad_medida = VALUES(
    unidad_medida),
  tipo_origen = 'producto',
  id_origen = NEW.id,
  fecha_actualizacion = CURRENT_TIMESTAMP;
ELSE
  DELETE
  FROM
          adminerp_copy.productos_siat
  WHERE
          tipo_origen = 'producto'
          AND id_origen = OLD.id;
END IF;
END
$$

--
-- Create trigger `trg_insert_producto_to_siat`
--
CREATE
DEFINER = 'root'@'localhost'
TRIGGER trg_insert_producto_to_siat
AFTER INSERT
ON alm_producto
FOR EACH ROW
BEGIN
IF NEW.estado = 'HAB'
  AND
  NEW.ind_permite_comandar = 70
THEN
  INSERT INTO adminerp_copy.productos_siat
        (
          codigo,
          nombre,
          unidad_medida,
          tipo_origen,
          id_origen
        )
  VALUES
      (
        NEW.codigo, NEW.nombre, SUBSTRING_INDEX (NEW.descripcion, ' ', 1), 'producto', NEW.id
      )
  ON DUPLICATE KEY UPDATE
  nombre = VALUES(
    nombre),
  unidad_medida = VALUES(
    unidad_medida),
  tipo_origen = 'producto',
  id_origen = NEW.id,
  fecha_actualizacion = CURRENT_TIMESTAMP;
END IF;
END
$$

DELIMITER ;

--
-- Create table `ope_precio_venta`
--
CREATE TABLE ope_precio_venta
  (
    id              INT(11)        NOT NULL AUTO_INCREMENT,
    precio_venta    DECIMAL(10, 2) NOT NULL,
    id_dia          INT(11)        NOT NULL,
    id_producto     INT(11)        DEFAULT NULL,
    id_combo_coctel INT(11)        DEFAULT NULL,
    usuario_reg     VARCHAR(255)   NOT NULL,
    fecha_reg       DATE           DEFAULT NULL,
    fecha_mod       DATE           DEFAULT NULL,
    estado          VARCHAR(3)     NOT NULL,
    PRIMARY KEY (id)
  )
ENGINE = INNODB,
AUTO_INCREMENT = 1621,
AVG_ROW_LENGTH = 80,
CHARACTER SET latin1,
COLLATE latin1_swedish_ci,
ROW_FORMAT = COMPACT;

--
-- Create index `fk_ope_precio_venta_alm_producto1_idx` on table `ope_precio_venta`
--
ALTER TABLE ope_precio_venta
ADD INDEX fk_ope_precio_venta_alm_producto1_idx (id_producto);

--
-- Create index `fk_ope_precio_venta_bar_combo_coctel1_idx` on table `ope_precio_venta`
--
ALTER TABLE ope_precio_venta
ADD INDEX fk_ope_precio_venta_bar_combo_coctel1_idx (id_combo_coctel);

--
-- Create index `fk_ope_precio_venta_ope_dia1_idx` on table `ope_precio_venta`
--
ALTER TABLE ope_precio_venta
ADD INDEX fk_ope_precio_venta_ope_dia1_idx (id_dia);

--
-- Create foreign key
--
ALTER TABLE ope_precio_venta
ADD CONSTRAINT fk_ope_precio_venta_ope_dia1 FOREIGN KEY (id_dia)
REFERENCES ope_dia (id) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Create foreign key
--
ALTER TABLE ope_precio_venta
ADD CONSTRAINT fk_ope_precio_venta_alm_producto1 FOREIGN KEY (id_producto)
REFERENCES alm_producto (id) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Create foreign key
--
ALTER TABLE ope_precio_venta
ADD CONSTRAINT fk_ope_precio_venta_bar_combo_coctel1 FOREIGN KEY (id_combo_coctel)
REFERENCES bar_combo_coctel (id) ON DELETE NO ACTION ON UPDATE NO ACTION;

DELIMITER $$

--
-- Create trigger `trg_update_precio_venta_to_siat`
--
CREATE
DEFINER = 'root'@'localhost'
TRIGGER trg_update_precio_venta_to_siat
AFTER UPDATE
ON ope_precio_venta
FOR EACH ROW
BEGIN
IF NEW.estado = 'HAB'
  AND
  NEW.id_dia = 1
THEN

  IF NEW.id_producto IS NOT NULL
  THEN
    UPDATE
    adminerp_copy.productos_siat
    SET
            precio_venta = NEW.precio_venta,
            fecha_actualizacion = CURRENT_TIMESTAMP
    WHERE
      tipo_origen = 'producto'
      AND id_origen = NEW.id_producto;
  END IF;

  IF NEW.id_combo_coctel IS NOT NULL
  THEN
    UPDATE
    adminerp_copy.productos_siat
    SET
            precio_venta = NEW.precio_venta,
            fecha_actualizacion = CURRENT_TIMESTAMP
    WHERE
      tipo_origen = 'combo'
      AND id_origen = NEW.id_combo_coctel;
  END IF;

ELSE
  -- Si cambia a estado distinto de HAB, borrar el precio
  IF NEW.id_producto IS NOT NULL
  THEN
    UPDATE
    adminerp_copy.productos_siat
    SET
            precio_venta = NULL,
            fecha_actualizacion = CURRENT_TIMESTAMP
    WHERE
      tipo_origen = 'producto'
      AND id_origen = NEW.id_producto;
  END IF;

  IF NEW.id_combo_coctel IS NOT NULL
  THEN
    UPDATE
    adminerp_copy.productos_siat
    SET
            precio_venta = NULL,
            fecha_actualizacion = CURRENT_TIMESTAMP
    WHERE
      tipo_origen = 'combo'
      AND id_origen = NEW.id_combo_coctel;
  END IF;
END IF;
END
$$

--
-- Create trigger `trg_insert_precio_venta_to_siat`
--
CREATE
DEFINER = 'root'@'localhost'
TRIGGER trg_insert_precio_venta_to_siat
AFTER INSERT
ON ope_precio_venta
FOR EACH ROW
BEGIN
IF NEW.estado = 'HAB'
  AND
  NEW.id_dia = 1
THEN

  IF NEW.id_producto IS NOT NULL
  THEN
    UPDATE
    adminerp_copy.productos_siat
    SET
            precio_venta = NEW.precio_venta,
            fecha_actualizacion = CURRENT_TIMESTAMP
    WHERE
      tipo_origen = 'producto'
      AND id_origen = NEW.id_producto;
  END IF;

  IF NEW.id_combo_coctel IS NOT NULL
  THEN
    UPDATE
    adminerp_copy.productos_siat
    SET
            precio_venta = NEW.precio_venta,
            fecha_actualizacion = CURRENT_TIMESTAMP
    WHERE
      tipo_origen = 'combo'
      AND id_origen = NEW.id_combo_coctel;
  END IF;

END IF;
END
$$

DELIMITER ;

--
-- Create table `bar_detalle_combo_bar`
--
CREATE TABLE bar_detalle_combo_bar
  (
    id                INT(11)        NOT NULL AUTO_INCREMENT,
    id_producto       INT(11)        NOT NULL,
    id_combo_coctel   INT(11)        NOT NULL,
    cantidad          DECIMAL(10, 2) NOT NULL,
    ind_paq_detalle   VARCHAR(1)     NOT NULL,
    ind_tipo_producto INT(11)        NOT NULL,
    usuario_reg       VARCHAR(255)   NOT NULL,
    fecha_reg         DATE           DEFAULT NULL,
    fecha_mod         DATE           DEFAULT NULL,
    estado            VARCHAR(3)     NOT NULL,
    PRIMARY KEY (id)
  )
ENGINE = INNODB,
AUTO_INCREMENT = 1014,
AVG_ROW_LENGTH = 97,
CHARACTER SET latin1,
COLLATE latin1_swedish_ci,
ROW_FORMAT = COMPACT;

--
-- Create index `fk_bar_detalle_combo_bar_alm_producto1_idx` on table `bar_detalle_combo_bar`
--
ALTER TABLE bar_detalle_combo_bar
ADD INDEX fk_bar_detalle_combo_bar_alm_producto1_idx (id_producto);

--
-- Create index `fk_bar_detalle_combo_bar_bar_combo_coctel1_idx` on table `bar_detalle_combo_bar`
--
ALTER TABLE bar_detalle_combo_bar
ADD INDEX fk_bar_detalle_combo_bar_bar_combo_coctel1_idx (id_combo_coctel);

--
-- Create foreign key
--
ALTER TABLE bar_detalle_combo_bar
ADD CONSTRAINT fk_bar_detalle_combo_bar_bar_combo_coctel1 FOREIGN KEY (id_combo_coctel)
REFERENCES bar_combo_coctel (id) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Create foreign key
--
ALTER TABLE bar_detalle_combo_bar
ADD CONSTRAINT fk_bar_detalle_combo_bar_alm_producto1 FOREIGN KEY (id_producto)
REFERENCES alm_producto (id) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Create table `parameter_table`
--
CREATE TABLE parameter_table
  (
    id          INT(11)        NOT NULL AUTO_INCREMENT,
    nombre      VARCHAR(255)   DEFAULT NULL,
    descripcion VARCHAR(255)   DEFAULT NULL,
    texto1      VARCHAR(255)   DEFAULT NULL,
    texto2      VARCHAR(255)   DEFAULT NULL,
    fechaInicio DATE           DEFAULT NULL,
    fechaFin    DATE           DEFAULT NULL,
    numero1     INT(11)        DEFAULT NULL,
    numero2     DECIMAL(10, 2) DEFAULT NULL,
    id_master   INT(11)        DEFAULT NULL,
    orden       INT(11)        DEFAULT NULL,
    requerido   VARCHAR(1)     DEFAULT NULL,
    estado      VARCHAR(3)     NOT NULL,
    PRIMARY KEY (id)
  )
ENGINE = INNODB,
AUTO_INCREMENT = 88,
AVG_ROW_LENGTH = 197,
CHARACTER SET latin1,
COLLATE latin1_swedish_ci,
ROW_FORMAT = COMPACT;

--
-- Create foreign key
--
ALTER TABLE parameter_table
ADD CONSTRAINT parameter_table_master_table_FK FOREIGN KEY (id_master)
REFERENCES master_table (id);