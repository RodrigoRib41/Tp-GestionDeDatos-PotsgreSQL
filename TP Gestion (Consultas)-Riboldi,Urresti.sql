Consulta 1: Cantidad de compras y ventas por cliente. 

(select c.dni_c,c.nombre_c,c.direccion,count(c.dni_c) + (select count(v.dni_c)
				                             from venta v
				                             where c.dni_c=v.dni_c ) Cant_operaciones
from cliente c, compra w
where  c.dni_c=w.dni_c
group by c.dni_c
order by Cant_Operaciones desc)

Consulta 2: Cantidad de vehiculos por marca vendidos.
select v.Marca,count(c.Codigo),max(c.Monto_Compra),min(c.Monto_Compra),sum(c.Monto_Compra)/count(c.Codigo) promedio
from compra c, vehiculo v
where c.Codigo=v.Codigo
group by v.Marca


Consulta 3: Vehiculos con sus dueños que realizaron todos los mantenimientos.
select c.dni_c,c.nombre_c,v.Matricula,v.Marca
from cliente c, compra c1,vehiculo v, vehiculo_mantenimiento m1
where c.dni_c=c1.dni_c and c1.Codigo=v.Codigo and v.Codigo=m1.Codigo 
group by v.Matricula,c.dni_c,v.Marca
having count(m1.ID_m)=
(select count(m.ID_m)
from mantenimiento_preventivo m)


Consulta 4: Mecanicos que intervinieron en más de 3 reparaciones cuya sumatoria de tiempo es mayor a 100 horas de
trabajo, en las tareas realizadas entre el 15/4/19 y el 20/4/19.
select m.nombre_m
from mecanico m
where 3 <=
(select count(m1.dni_m) 
            from mecanico m1,reparacion r 
            where m1.dni_m=m.dni_m and m1.dni_m=r.dni_m and 
            r.fecha_reparacion between '15-04-2019' and '20-04-2019' 
            group by m1.dni_m)
 and 100 <=( select sum(r.cant_horas)                                    
             from mecanico m1,reparacion r                                          
             where m1.dni_m=m.dni_m and m1.dni_m=r.dni_m and 
              r.fecha_reparacion between '15-04-2019' and '20-04-2019' 
             group by m1.dni_m)


Consulta 5: Mecánicos que solo han participado en tareas de reparación
select m.dni_m, m.nombre_m
from mecanico m, reparacion r
where m.dni_m=r.dni_m and r.dni_m not in (select m1.dni_m
					 from mantenimiento_preventivo m1
	                                 group by m1.dni_m)


Consulta 6: Vehículos que están o estuvieron vinculados a la
concesionaria y la ganancia obtenida de los mismos.

create view vista_consulta_6 (codigo,ganancia) as (select ve.codigo , sum(ve.monto_venta*-1) 
from venta ve
group by ve.codigo										   
union 
select cr.codigo, sum(cr.monto_compra) 
from compra cr
group by cr.codigo
)
select codigo, sum(ganancia) ganancia
from vista_consulta_6
group by codigo

Consulta 7: Automóviles a la venta que tenga un valor menor a $ 300.000 y que
tengan como equipamiento: airbags delanteros, bluetooth y ABS. 

select v.matricula,v.marca,v.año_motor
from vehiculo v, confort c1 ,seguridad s1, seguridad s2
where v.codigo !=all(select v1.codigo
                     from vehiculo v1,compra c
                     where c.codigo=v1.codigo)
and v.valor<=300000 and c1.codigo=v.codigo and 
c1.tipo_c='Bluetooh' and s1.codigo=v.codigo and 
s1.tipo_s='ABS' and s2.tipo_s='AirBag'
group by  v.matricula,v.marca,v.año_motor

Consulta 8: Vendedores con la cantidad de vehículos vendidos, y el monto total por ventas
(en el 2018). En la última columna de este reporte se calcula el 4 % del total de
ventas correspondiente a su comisión.

select v.nombre_v ,count(v1.dni_v) cantidad_vendida,sum(v1.monto_venta) monto_total,sum(v1.monto_venta)*0.04 comision
from vendedor v,venta v1
where v.dni_v=v1.dni_v and v1.fecha_venta between '01-01-2018' and '31-12-2018'
group by v.nombre_v
order by cantidad_vendida desc