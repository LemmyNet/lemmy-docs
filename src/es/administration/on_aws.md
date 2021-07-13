# Instalando en AWS

> ⚠️ **Descargo de responsabilidad:** este método de instalación no está recomendado por los desarrolladores de Lemmy. Si tienes algún problema, debes resolverlo tú mismo o preguntar a los respectivos autores. Si observas algún fallo de Lemmy en una instancia instalada de este modo, por favor, menciónalo en el informe de fallos.

## Lemmy AWS CDK

Contiene las definiciones de infraestructura necesarias para desplegar [Lemmy](https://github.com/LemmyNet/lemmy) en AWS su [Cloud Development Kit](https://docs.aws.amazon.com/cdk/latest/guide/home.html).

### Incluye:

* ECS fargate cluster
  * Lemmy-UI
  * Lemmy
  * Pictrs
  * IFramely
* CloudFront CDN
* Almacenamiento EFS para subir imágenes.
* Aurora Serverless Postgres DB
* Bastion VPC host
* Balanceadores de carga para Lemmy y IFramely
* Registros DNS para tu sitio.

## Inicio rápido

Clona el [Lemmy-CDK]( https://github.com/jetbridge/lemmy-cdk). 

Clona [Lemmy](https://github.com/LemmyNet/lemmy) y [Lemmy-UI](https://github.com/LemmyNet/lemmy-ui) en el directorio de arriba.

```shell
cp example.env.local .env.local
# edit .env.local
```

Debes editar .env.local con la configuración de tu sitio.

```shell
npm install -g aws-cdk
npm install
cdk bootstrap
cdk deploy
```

## Coste
Esta *no* es la forma más barata de ejecutar Lemmy. La base de datos sin servidor (serverless) Aurora puede costarte ~$90/mes (en dólares) si no duerme.

## Comandos del CDK útiles

* `npm run build`   compila typescript a js
* `npm run watch`   vigila los cambios y compila
* `npm run test`    realiza las pruebas unitarias de jest
* `cdk deploy`      despliega esta pila en tu cuenta/región de AWS por defecto
* `cdk diff`        compara la pila desplegada con el estado actual
* `cdk synth`       emite la plantilla de CloudFormation sintetizada
