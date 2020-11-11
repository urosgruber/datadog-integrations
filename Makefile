# $FreeBSD$

PORTNAME=	datadog-integrations
DISTVERSION=	7.23.0
CATEGORIES=	sysutils

MAINTAINER=	uros@gruber.si
COMMENT=	Datadog Agent Integrations

LICENSE=	BSD4CLAUSE
LICENSE_FILE=	${WRKSRC}/LICENSE

BUILD_DEPENDS=	${PYTHON_PKGNAMEPREFIX}setuptools>0:devel/py-setuptools@${PY_FLAVOR}

RUN_DEPENDS=	datadog>=${DISTVERSION}:sysutils/datadog \
		${PYTHON_PKGNAMEPREFIX}typing-extensions>0:devel/py-typing-extensions@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}requests-unixsocket>0:www/py-requests-unixsocket@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}simplejson>0:devel/py-simplejson@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}requests>0:www/py-requests@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}requests-toolbelt>0:www/py-requests-toolbelt@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}yaml>0:devel/py-yaml@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}uptime>0:sysutils/py-uptime@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}typing-extensions>0:devel/py-typing-extensions@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}service_identity>0:security/py-service_identity@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}psutil>0:sysutils/py-psutil@${PY_FLAVOR} \
		${PYTHON_PKGNAMEPREFIX}pymysql>0:databases/py-pymysql@${PY_FLAVOR}

USES=		python:3.7+

ETCDIR=		${PREFIX}/etc/datadog

USE_GITHUB=	yes
GH_ACCOUNT=	DataDog
GH_PROJECT=	integrations-core
GH_TAGNAME=	${DISTVERSION}

NO_BUILD=	yes
NO_ARCH=	yes

# find integrations-core -name setup.py | awk -F\/ '{print $2}' | sort | uniq | grep -v datadog_checks_dev | tr '\n' ' '
INTEGRATIONS=	tls network datadog_checks_base

# find integrations-core -name conf.yaml.example | awk -F\/ '{print $2}' | sort | uniq | grep -v datadog_checks_dev | tr '\n' ' '
CONFFILES=	tls network

do-install:
	${MKDIR} ${STAGEDIR}${ETCDIR}
	${MKDIR} ${STAGEDIR}${ETCDIR}/conf.d

	# Install core-integrations
.for dir in ${INTEGRATIONS}
	(cd ${WRKSRC}/${dir}; \
	${PYTHON_CMD} setup.py bdist; \
	${TAR} -xzf dist/*.tar.gz -C ${STAGEDIR})
.endfor

post-install:
	# Install core-integrations
.for dir in ${CONFFILES}
	(cd ${WRKSRC}/${dir}; \
	${MV} datadog_checks/${dir}/data ${STAGEDIR}${ETCDIR}/conf.d/${dir}.d)
.endfor

.include <bsd.port.mk>
