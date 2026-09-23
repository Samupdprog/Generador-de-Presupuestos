# Motor de presupuestos

El motor recibe estado y operaciones tipadas y produce un presupuesto calculado.

Debe ser determinista: mismo estado + mismas operaciones = mismo resultado.

## Dos capas de precio

### Regla de venta de línea

Ejemplos:

- precio por unidad;
- total fijo de línea;
- sumar euros por unidad;
- sumar porcentaje según su regla.

### Ajustes posteriores

Actúan sobre un precio ya calculado:

- subir una línea;
- varias líneas;
- presupuesto completo;
- añadir euros;
- porcentaje;
- fijar un nuevo total.

Los ajustes son operaciones auditables. No convierten automáticamente la regla original de una línea a `fixed_line_total`.

## Dinero

El dominio trabaja con `Decimal`.

Los límites de red pueden usar strings decimales.

Nunca se usa un float JavaScript como representación canónica de dinero.
