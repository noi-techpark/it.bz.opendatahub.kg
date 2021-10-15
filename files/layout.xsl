<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [
    <!ENTITY lapp   "https://w3id.org/atomgraph/linkeddatahub/apps/domain#">
    <!ENTITY apl    "https://w3id.org/atomgraph/linkeddatahub/domain#">
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
exclude-result-prefixes="#all">

    <xsl:import href="../../../../com/atomgraph/linkeddatahub/xsl/bootstrap/2.3.2/layout.xsl"/>

    <xsl:param name="apl:baseUri" as="xs:anyURI" static="yes"/>

    <xsl:template match="rdf:RDF" mode="xhtml:Style">
        <xsl:apply-imports/>

        <style type="text/css">
            <![CDATA[
            body { font-family: "Open Sans", Arial, sans-serif; color: black; font-size: 16px; }
            .brand img { height: 1em; }
            .navbar .nav > li > a { color: black; letter-spacing: 2px; font-size: 0.8rem; font-weight: 400; text-shadow: none; }
            .navbar-inner { background-color: white; }
            .action-bar { background-color: #f5f5f5; }
            .progress-striped .bar { background-color: #50742F; }
            a, a:hover, a:focus, .navbar .brand, .nav-list > li > a  { color: black; }
            .well { background-color: #f5f5f5; }
            div.span7 h2, .navbar .brand { font-weight: 700; }
            div.span7 h2 a:after { content: " \279E"; }
            #map { width: 100%; height: 400px; }
            .footer { background-color: #50742F; color: white; padding-top: 5rem; font-size: unset; }
            .footer .nav-header { font-family: "Open Sans", Arial, sans-serif; font-size: 1.2rem; color: white; line-height: 1.8; text-transform: unset; }
            .footer .nav-list > li > a { color: white; }
            ]]>
        </style>

        <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/openlayers/openlayers.github.io@master/en/v6.6.1/css/ol.css" type="text/css"/>
    </xsl:template>

    <xsl:template match="rdf:RDF" mode="xhtml:Script">
        <xsl:apply-imports>
            <xsl:with-param name="client-stylesheet" select="resolve-uri('static/it/bz/opendatahub/kg/xsl/client.xsl.sef.json', $ac:contextUri)"/>
        </xsl:apply-imports>

        <!-- OpenLayers and WKTMap -->
        <script src="https://cdn.jsdelivr.net/gh/openlayers/openlayers.github.io@master/en/v6.6.1/build/ol.js"></script>
        <script src="{resolve-uri('static/it/bz/opendatahub/kg/js/WKTMap.js', $apl:baseUri)}" type="text/javascript"></script>
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
        <a class="brand offset2 span1" href="{$apl:base}">
            <img alt="{ac:label($apl:client//*[@rdf:about])}" src="{$apl:client//foaf:logo/@rdf:resource}"/>
        </a>
    </xsl:template>

    <!-- in the end-user app, retrieve the select-children SELECT query, wrap it into a DESCRIBE and render root container nav bar instead of the search bar -->
    <xsl:template match="rdf:RDF[$apl:client//rdf:type/@rdf:resource = '&lapp;EndUserApplication']" mode="bs2:SearchBar">
        <xsl:variable name="query-uri" select="resolve-uri('queries/default/select-children/#this', $apl:base)" as="xs:anyURI"/>
        <xsl:variable name="select-string" select="key('resources', $query-uri, document(ac:document-uri($query-uri)))/sp:text" as="xs:string"/>
        <xsl:variable name="regex-groups" select="analyze-string(normalize-space($select-string), '^(.*)(SELECT)(.*)$', 'i')" as="element()"/>
        <xsl:variable name="query-string" select="$regex-groups/fn:match[1]/fn:group[@nr = '1']/string() || ' DESCRIBE ?child { ' || $regex-groups/fn:match[1]/fn:group[@nr = '2']/string() || $regex-groups/fn:match[1]/fn:group[@nr = '3']/string() || ' }'" as="xs:string"/>
        <xsl:variable name="query-string" select="replace($query-string, '\?this', concat('&lt;', $apl:base, '&gt;'))" as="xs:string"/>
        <xsl:variable name="results-uri" select="ac:build-uri(resolve-uri('sparql', $apl:base),  map{ 'query': $query-string })" as="xs:anyURI"/>

        <xsl:if test="doc-available($results-uri)">
            <ul class="nav span5">
                <xsl:apply-templates select="document($results-uri)//rdf:Description" mode="bs2:List">
                    <xsl:sort select="ac:label(.)"/>
                    <xsl:with-param name="active" select="@rdf:about = $ac:uri"/>
                </xsl:apply-templates>
            </ul>
        </xsl:if>
    </xsl:template>

    <xsl:template match="rdf:RDF" mode="bs2:SignUp"/>

    <xsl:template match="*[schema:image/@rdf:resource]" mode="ac:image">
        <xsl:sequence select="schema:image/@rdf:resource"/>
    </xsl:template>

    <!-- rewrite http:// as https:// -->
<!--     <xsl:template match="*[@rdf:about][starts-with(@rdf:about, 'http://noi.example.org/')]" mode="xhtml:Anchor">
        <xsl:next-match>
            <xsl:with-param name="href" select="xs:anyURI('https://noi.example.org/' || substring-after(@rdf:about, 'http://noi.example.org/'))"/>
        </xsl:next-match>
    </xsl:template>
     -->
    <!-- rewrite http:// as https:// -->
<!--     <xsl:template match="@rdf:resource[starts-with(., 'http://noi.example.org/')]">
        <xsl:next-match>
            <xsl:with-param name="href" select="xs:anyURI('https://noi.example.org/' || substring-after(., 'http://noi.example.org/'))"/>
        </xsl:next-match>
    </xsl:template>
     -->
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

    <xsl:template match="schema:containsPlace | schema:containsPlace/@rdf:resource" priority="1"/>

    <xsl:template match="gs:defaultGeometry/@rdf:resource" priority="1">
        <!-- <xsl:variable name="uri" select="xs:anyURI('https://noi.example.org/' || substring-after(., 'http://noi.example.org/'))" as="xs:anyURI"/> -->
        <xsl:variable name="uri" select="." as="xs:anyURI"/>
        <!-- TO-DO: we need to proxy the URI as long as the https/http base URIs don't align -->
        <xsl:variable name="doc-uri" select="xs:anyURI($ldt:base || '?uri=' || encode-for-uri(ac:document-uri($uri)))" as="xs:anyURI"/> <!-- select="ac:document-uri(.)" -->
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
    <xsl:template match="*[rdf:type/@rdf:resource = ('http://noi.example.org/ontology/odh#Municipality', '&schema;LodgingBusiness')]" mode="xhtml:Body" priority="1">
        <div class="row-fluid">
            <xsl:apply-templates select="." mode="bs2:Left"/>

            <xsl:apply-templates select="." mode="bs2:Main"/>

            <xsl:apply-templates select="." mode="bs2:Right"/>
        </div>
        
        <xsl:apply-templates select="key('resources', apl:content/@rdf:*)" mode="apl:ContentList"/>

        <!-- this URI resolution will only work with https://noi.example.org/data/ base URI -->
        <xsl:variable name="ontology" select="resolve-uri('../admin/model/ontologies/noi/#', $ldt:base)" as="xs:anyURI"/>
        <xsl:if test="doc-available(ac:document-uri($ontology))">
            <xsl:apply-templates select="key('resources', resolve-uri($ontology || 'ContainedPlaces', $ldt:base), document(ac:document-uri($ontology)))" mode="apl:ContentList"/>
        </xsl:if>
    </xsl:template>

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
        </div>
    </xsl:template>

</xsl:stylesheet>