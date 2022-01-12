<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [
    <!ENTITY lapp   "https://w3id.org/atomgraph/linkeddatahub/apps/domain#">
    <!ENTITY apl    "https://w3id.org/atomgraph/linkeddatahub/domain#">
    <!ENTITY def    "https://w3id.org/atomgraph/linkeddatahub/default#">
    <!ENTITY ac     "https://w3id.org/atomgraph/client#">
    <!ENTITY rdf    "http://www.w3.org/1999/02/22-rdf-syntax-ns#">
    <!ENTITY rdfs   "http://www.w3.org/2000/01/rdf-schema#">
    <!ENTITY ldt    "https://www.w3.org/ns/ldt#">
    <!ENTITY sp     "http://spinrdf.org/sp#">
    <!ENTITY gs     "http://www.opengis.net/ont/geosparql#">
    <!ENTITY schema "http://schema.org/">
    <!ENTITY foaf   "http://xmlns.com/foaf/0.1/">
]>
<xsl:stylesheet version="3.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:fn="http://www.w3.org/2005/xpath-functions"
xmlns:xhtml="http://www.w3.org/1999/xhtml"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:lapp="&lapp;"
xmlns:apl="&apl;"
xmlns:ac="&ac;"
xmlns:rdf="&rdf;"
xmlns:rdfs="&rdfs;"
xmlns:ldt="&ldt;"
xmlns:sp="&sp;"
xmlns:gs="&gs;"
xmlns:schema="&schema;"
xmlns:foaf="&foaf;"
xmlns:bs2="http://graphity.org/xsl/bootstrap/2.3.2"
xmlns:functx="http://www.functx.com"
exclude-result-prefixes="#all">

    <xsl:import href="../../../../../com/atomgraph/linkeddatahub/xsl/bootstrap/2.3.2/layout.xsl"/>

    <xsl:param name="apl:base" as="xs:anyURI" static="yes"/>

    <xsl:function name="functx:camel-case-to-words" as="xs:string">
        <xsl:param name="arg" as="xs:string?"/>
        <xsl:param name="delim" as="xs:string"/>

        <xsl:sequence select="
        concat(substring($arg,1,1),
                 replace(substring($arg,2),'(\p{Lu})',
                            concat($delim, '$1')))
        "/>

    </xsl:function>

    <xsl:function name="functx:capitalize-first" as="xs:string?">
        <xsl:param name="arg" as="xs:string?"/>

        <xsl:sequence select="
        concat(upper-case(substring($arg,1,1)),
                 substring($arg,2))
        "/>

    </xsl:function>

    <xsl:template match="rdf:RDF" mode="xhtml:Style">
        <xsl:apply-imports>
            <xsl:with-param name="load-wymeditor" select="false()"/>
            <xsl:with-param name="load-yasqe" select="false()"/>
        </xsl:apply-imports>

        <link rel="icon" href="{resolve-uri('static/favicon.ico', $apl:base)}" type="image/x-icon"/>
        <link rel="stylesheet" href="{resolve-uri('static/it/bz/opendatahub/kg/css/bootstrap.css', $ac:contextUri)}" type="text/css"/>
        <link rel="stylesheet" href="{resolve-uri('static/it/bz/opendatahub/kg/css/bootstrap-responsive.css', $ac:contextUri)}" type="text/css"/>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/openlayers/openlayers.github.io@master/en/v6.6.1/css/ol.css" type="text/css"/>
    </xsl:template>

    <xsl:template match="rdf:RDF" mode="xhtml:Script">
        <xsl:apply-imports>
            <!-- not using SPARQLMap + Google Maps, using OpenLayers instead -->
            <xsl:with-param name="load-sparql-map" select="false()"/>
            <!-- not showing the SPARQL editor anywhere, so exclude the YASQE editor -->
            <xsl:with-param name="load-yasqe" select="false()"/>
            <xsl:with-param name="client-stylesheet" select="resolve-uri('static/it/bz/opendatahub/kg/xsl/client.xsl.sef.json', $ac:contextUri)"/>
        </xsl:apply-imports>

        <!-- OpenLayers and WKTMap -->
        <script src="https://cdn.jsdelivr.net/gh/openlayers/openlayers.github.io@master/en/v6.6.1/build/ol.js"></script>
        <script src="{resolve-uri('static/it/bz/opendatahub/kg/js/WKTMap.js', $apl:base)}" type="text/javascript"></script>
    </xsl:template>

    <xsl:template match="rdf:RDF" mode="bs2:NavBar">
        <div class="navbar navbar-fixed-top">
            <div class="navbar-inner">
                <div class="container-fluid">
                    <button class="btn btn-navbar">
                        <span class="icon-bar"></span>
                        <span class="icon-bar"></span>
                        <span class="icon-bar"></span>
                    </button>

                    <div id="collapsing-top-navbar" class="nav-collapse collapse row-fluid">
                        <xsl:apply-templates select="." mode="bs2:Brand"/>

                        <xsl:apply-templates select="." mode="bs2:SearchBar"/>

                        <a class="brand span1" href="https://noi.bz.it" target="_blank">
                            <img alt="NOI Techpark" src="https://opendatahub.bz.it/img/NOI_1_BK.svg"/>
                        </a>
                    </div>
                </div>
            </div>

            <xsl:apply-templates select="." mode="bs2:ActionBar"/>
        </div>
    </xsl:template>

    <xsl:template match="rdf:RDF" mode="bs2:Brand">
        <a class="brand offset2 span1" href="{$ldt:base}">
            <img alt="{ac:label($lapp:Application//*[ldt:base/@rdf:resource = $ldt:base])}" src="{$lapp:Application//foaf:logo/@rdf:resource}"/>
        </a>
    </xsl:template>

    <!-- in the end-user app, retrieve the select-children SELECT query, wrap it into a DESCRIBE and render root container nav bar instead of the search bar -->
    <xsl:template match="rdf:RDF[$lapp:Application//*[ldt:base/@rdf:resource = $ldt:base]/rdf:type/@rdf:resource = '&lapp;EndUserApplication']" mode="bs2:SearchBar">
        <xsl:variable name="query-uri" select="xs:anyURI('&def;SelectChildren')" as="xs:anyURI"/>
        <xsl:variable name="select-string" select="key('resources', $query-uri, document(ac:document-uri($query-uri)))/sp:text" as="xs:string"/>
        <xsl:variable name="regex-groups" select="analyze-string(normalize-space($select-string), '^(.*)(SELECT)(.*)$', 'i')" as="element()"/>
        <xsl:variable name="query-string" select="$regex-groups/fn:match[1]/fn:group[@nr = '1']/string() || ' DESCRIBE ?child { ' || $regex-groups/fn:match[1]/fn:group[@nr = '2']/string() || $regex-groups/fn:match[1]/fn:group[@nr = '3']/string() || ' }'" as="xs:string"/>
        <xsl:variable name="query-string" select="replace($query-string, '\?this', concat('&lt;', $ldt:base, '&gt;'))" as="xs:string"/>
        <xsl:variable name="results-uri" select="ac:build-uri(resolve-uri('sparql', $ldt:base),  map{ 'query': $query-string })" as="xs:anyURI"/>

        <xsl:if test="doc-available($results-uri)">
            <ul class="nav span5">
                <xsl:for-each select="document($results-uri)//rdf:Description">
                    <xsl:sort select="ac:label(.)"/>
                    <xsl:apply-templates select="." mode="bs2:List">
                        <xsl:with-param name="active" select="@rdf:about = $ac:uri"/>
                    </xsl:apply-templates>
                </xsl:for-each>
            </ul>
        </xsl:if>
    </xsl:template>

    <xsl:template match="rdf:RDF" mode="bs2:SignUp"/>

    <xsl:template match="*[schema:image/@rdf:resource]" mode="ac:image">
        <xsl:sequence select="schema:image/@rdf:resource"/>
    </xsl:template>

    <xsl:template match="*[schema:name[lang($ldt:lang)]/text()]" mode="ac:label" priority="1">
        <xsl:sequence select="schema:name[lang($ldt:lang)]/text()"/>
    </xsl:template>
    
    <xsl:template match="*[schema:name/text()]" mode="ac:label">
        <xsl:sequence select="schema:name/text()"/>
    </xsl:template>

    <xsl:template match="*[schema:description[lang($ldt:lang)]/text()]" mode="ac:description" priority="1">
        <xsl:sequence select="schema:description[lang($ldt:lang)]/text()"/>
    </xsl:template>
    
    <xsl:template match="*[schema:description/text()]" mode="ac:description">
        <xsl:sequence select="schema:description/text()"/>
    </xsl:template>

    <!-- do not derefence these properties, build label from URL path instead -->
    <xsl:template match="schema:*" mode="ac:property-label">
        <xsl:variable name="this" select="concat(namespace-uri(), local-name())"/>

        <xsl:sequence select="functx:capitalize-first(functx:camel-case-to-words($this,' '))"/>
    </xsl:template>

    <!-- do not dereference these objects to get their labels, use the last path segment instead -->
    <xsl:template match="schema:address/@rdf:resource | schema:hasMenu/@rdf:resource | schema:aggregateRating/@rdf:resource | schema:isPartOf/@rdf:resource | schema:geo/@rdf:resource | schema:hasGeometry/@rdf:resource" mode="ac:object-label">
        <xsl:sequence select="tokenize(., '/')[last()]"/>
    </xsl:template>

    <!-- do not derefence these objects, build label from URL path instead -->
    <xsl:template match="@rdf:resource[starts-with(., '&schema;')]" mode="ac:object-label">
        <xsl:sequence select="functx:capitalize-first(functx:camel-case-to-words(.,' '))"/>
    </xsl:template>

    <xsl:template match="schema:image/@rdf:resource" priority="1">
        <a href="{.}">
            <img src="{.}">
                <xsl:attribute name="alt">
                    <xsl:value-of>
                        <xsl:apply-templates select="." mode="ac:object-label"/>
                    </xsl:value-of>
                </xsl:attribute>
            </img>
        </a>
    </xsl:template>

    <xsl:template match="schema:url/@rdf:resource" priority="1">
        <xsl:next-match>
            <xsl:with-param name="target" select="'_blank'"/>
        </xsl:next-match>
    </xsl:template>

    <xsl:template match="schema:email/text()">
        <a title="{.}" href="mailto:{.}">
            <xsl:value-of select="."/>
        </a>
    </xsl:template>

    <xsl:template match="schema:telephone/text()">
        <a title="{.}" href="tel:{encode-for-uri(.)}">
            <xsl:value-of select="."/>
        </a>
    </xsl:template>

    <xsl:template match="schema:containsPlace | schema:containsPlace/@rdf:resource" mode="#all" priority="1"/>

    <xsl:template match="gs:defaultGeometry/@rdf:resource" priority="1">
        <xsl:variable name="uri" select="." as="xs:anyURI"/>
        <!-- TO-DO: we need to proxy the URI as long as the https/http base URIs don't align -->
        <xsl:variable name="doc-uri" select="ac:document-uri(.)" as="xs:anyURI"/>
        <xsl:choose>
            <xsl:when test="doc-available($doc-uri)">
                <xsl:variable name="wkt-literal" select="key('resources', ., document($doc-uri))/gs:asWKT" as="xs:string"/>
                <input type="hidden" name="wkt" value="{$wkt-literal}"/>

                <div id="map"></div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- append content with places contained in this resource -->
    <xsl:template match="*[rdf:type/@rdf:resource = ('http://noi.example.org/ontology/odh#Municipality', '&schema;LodgingBusiness')]" mode="bs2:RowBlock" priority="1">
        <xsl:param name="id" select="generate-id()" as="xs:string?"/>
        <xsl:param name="content-uri" as="xs:anyURI?"/>
        <xsl:param name="class" select="'row-fluid'" as="xs:string?"/>

        <div>
            <xsl:if test="$id">
                <xsl:attribute name="id"><xsl:sequence select="$id"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="$class">
                <xsl:attribute name="class"><xsl:sequence select="$class"/></xsl:attribute>
            </xsl:if>

            <xsl:apply-templates select="." mode="bs2:Left"/>

            <div class="span7">
                <xsl:apply-templates select="." mode="bs2:Block"/>
                
                <xsl:if test="$content-uri">
                    <div id="{$id || '-content'}" class="content resource-content" data-content-uri="{$content-uri}"/>
                </xsl:if>
            </div>

            <xsl:apply-templates select="." mode="bs2:Right"/>
        </div>
        
        <xsl:variable name="ontology" select="resolve-uri('admin/model/ontologies/namespace/', $ldt:base)" as="xs:anyURI"/>
        <xsl:if test="doc-available(ac:document-uri($ontology))">
            <xsl:apply-templates select="key('resources', $ontology || '#ContainedPlaces', document(ac:document-uri($ontology)))" mode="apl:ContentList"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="rdf:RDF" mode="bs2:ModeTabs"/>

    <xsl:template match="*[*][@rdf:about]" mode="apl:ContentHeader"/>

    <xsl:template match="rdf:RDF" mode="bs2:Footer">
        <div class="footer container-fluid">
            <div class="row-fluid">
                <div class="offset2 span8">
                    <div class="span3">
                        <a href="https://opendatahub.bz.it" target="_blank">
                            <img alt="OpenDataHub" src="https://opendatahub.bz.it/img/logo-open-data-hub_white.png"/>
                        </a>
                    </div>
                    <div class="span3">
                        <h2 class="nav-header">Data</h2>
                        <ul class="nav nav-list">
                            <li><a href="https://opendatahub.bz.it/datasets" target="_blank">Datasets</a></li>
                            <li><a href="https://webcomponents.opendatahub.bz.it/" target="_blank">Web components</a></li>
                        </ul>
                    </div>
                    <div class="span3">
                        <h2 class="nav-header">Community</h2>
                        <ul class="nav nav-list">
                            <li><a href="https://opendatahub.bz.it/community" target="_blank">Community</a></li>
                            <li><a href="https://opendatahub.bz.it/events" target="_blank">Events</a></li>
                        </ul>
                    </div>
                    <div class="span3">
                        <h2 class="nav-header">Services</h2>
                        <ul class="nav nav-list">
                            <li><a href="https://opendatahub.bz.it/data-access/" target="_blank">Data Access</a></li>
                            <li><a href="https://opendatahub.bz.it/data-sharing/" target="_blank">Data Sharing</a></li>
                            <li><a href="https://opendatahub.bz.it/services#app-dev" target="_blank">Data Visualization</a></li>
                        </ul>
                    </div>
                </div>
            </div>
            <div class="row-fluid">
                <div class="offset2 span8">
                    <p class="text-left">
                        Knowledge Graph platform: <a href="https://atomgraph.github.io/LinkedDataHub/" target="_blank">LinkedDataHub</a> by <a href="https://atomgraph.com" target="_blank">AtomGraph</a>
                    </p>
                </div>
            </div>
        </div>
    </xsl:template>

</xsl:stylesheet>