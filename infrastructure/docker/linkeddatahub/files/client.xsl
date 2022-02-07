<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:ixsl="http://saxonica.com/ns/interactiveXSLT"
xmlns:xhtml="http://www.w3.org/1999/xhtml"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:ldh="https://w3id.org/atomgraph/linkeddatahub#"
xmlns:ac="https://w3id.org/atomgraph/client#"
xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
xmlns:ldt="https://www.w3.org/ns/ldt#"
xmlns:schema="http://schema.org/"
xmlns:bs2="http://graphity.org/xsl/bootstrap/2.3.2"
exclude-result-prefixes="#all">

    <xsl:import href="../../../../../com/atomgraph/linkeddatahub/xsl/client.xsl"/>

    <xsl:param name="map-center" select="map{ 'x': 1264010.55, 'y': 5860564.91 }" as="map(xs:string, xs:float)"/>
    <xsl:param name="map-zoom" select="8" as="xs:integer"/>
    <xsl:param name="backlinks-string" as="xs:string">
<![CDATA[
PREFIX schema: <http://schema.org/>

DESCRIBE ?subject
WHERE
  { SELECT DISTINCT  ?subject
    WHERE
      {   { ?subject  ?p  ?this }
        UNION
          { GRAPH ?g
              { ?subject  ?p  ?this }
          }
        FILTER (?p NOT IN (schema:image))
        FILTER isURI(?subject)
      }
    LIMIT   10
  }
]]></xsl:param>

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

    <xsl:template match="*[schema:image/@rdf:resource]" mode="ac:image">
        <xsl:sequence select="schema:image/@rdf:resource"/>
    </xsl:template>

    <xsl:template match="/" mode="ldh:LoadedHTMLDocument">
        <xsl:param name="href" as="xs:anyURI?"/>
        <xsl:param name="uri" select="ldh:absolute-path($href)" as="xs:anyURI?"/>
        <xsl:param name="fragment" as="xs:string?"/>
        <xsl:param name="container" as="element()"/>
        <xsl:param name="push-state" select="true()" as="xs:boolean"/>

        <xsl:next-match>
            <xsl:with-param name="href" select="$href"/>
            <xsl:with-param name="fragment" select="$fragment"/>
            <xsl:with-param name="container" select="$container"/>
            <xsl:with-param name="push-state" select="$push-state"/>
        </xsl:next-match>

        <xsl:for-each select="ixsl:page()//div[tokenize(@class, ' ') = 'navbar']//ul/li">
            <!-- make all <li> inactive -->
            <xsl:sequence select="ixsl:call(ixsl:get(., 'classList'), 'toggle', [ 'active', false() ])[current-date() lt xs:date('2000-01-01')]"/>
        </xsl:for-each>
        <xsl:for-each select="ixsl:page()//div[tokenize(@class, ' ') = 'navbar']//ul/li[a[starts-with(ac:uri(), @href)]]">
            <!-- set .active class on the <li> which has a link matching this document -->
            <xsl:sequence select="ixsl:call(ixsl:get(., 'classList'), 'toggle', [ 'active', true() ])[current-date() lt xs:date('2000-01-01')]"/>
        </xsl:for-each>

        <xsl:if test="//input[@name = 'wkt']">
            <xsl:variable name="wkt-literal" select="//input[@name = 'wkt']/@value" as="xs:string"/>
            <xsl:variable name="js-statement" as="element()">
                <root statement="new WKTMap.WKTMap(document.getElementById('map'), new ol.View({{ center: [ {$map-center?x}, {$map-center?y}], zoom: {$map-zoom} }}))"/>
            </xsl:variable>
            
            <xsl:variable name="map" select="ixsl:eval(string($js-statement/@statement))"/>
            <!-- render map -->
            <xsl:sequence select="ixsl:call($map, 'render', [ $wkt-literal ])[current-date() lt xs:date('2000-01-01')]"/>
            
            <!-- fit the map to the polygon -->
            <xsl:variable name="fit-options" select="ldh:new-object()"/>
            <ixsl:set-property name="maxZoom" select="$map-zoom" object="$fit-options"/>
            <xsl:sequence select="ixsl:call(ixsl:call($map, 'getView', []), 'fit', [ ixsl:call(ixsl:call($map, 'getFeature', []), 'getGeometry', []), $fit-options ])[current-date() lt xs:date('2000-01-01')]"/>
        </xsl:if>
    </xsl:template>

    <!-- do not intercept RDF download links -->
    <xsl:template match="button[@id = 'export-rdf']/following-sibling::ul//a" mode="ixsl:onclick" priority="1"/>

    <!-- intercept links in the navbar's <ul> -->
    <xsl:template match="a[not(@target)][starts-with(@href, 'http://') or starts-with(@href, 'https://')][not(starts-with(@href, resolve-uri('uploads/', $ldt:base)))][ancestor::div[tokenize(@class, ' ') = 'navbar']//ul]" mode="ixsl:onclick">
        <xsl:sequence select="ixsl:call(ixsl:event(), 'preventDefault', [])"/>
        <xsl:variable name="href" select="xs:anyURI(@href)" as="xs:anyURI"/>
        <!-- indirect resource URI, dereferenced through a proxy -->
        <xsl:variable name="request-uri" select="ac:build-uri($ldt:base, map{ 'uri': string($href) })" as="xs:anyURI"/>
        
        <ixsl:set-style name="cursor" select="'progress'" object="ixsl:page()//body"/>
        
        <ixsl:schedule-action http-request="map{ 'method': 'GET', 'href': $request-uri, 'headers': map{ 'Accept': 'application/xhtml+xml' } }">
            <xsl:call-template name="onDocumentLoad">
                <xsl:with-param name="href" select="ac:document-uri($href)"/>
                <xsl:with-param name="fragment" select="encode-for-uri($href)"/>
            </xsl:call-template>
        </ixsl:schedule-action>

        <!-- set .active class on the parent <li> -->
        <xsl:for-each select="..">
            <xsl:sequence select="ixsl:call(ixsl:get(., 'classList'), 'toggle', [ 'active', true() ])[current-date() lt xs:date('2000-01-01')]"/>
        </xsl:for-each>
        <!-- make other <li> inactive -->
        <xsl:for-each select="../preceding-sibling::* | ../following-sibling::*">
            <xsl:sequence select="ixsl:call(ixsl:get(., 'classList'), 'toggle', [ 'active', false() ])[current-date() lt xs:date('2000-01-01')]"/>
        </xsl:for-each>
    </xsl:template>

    <!-- disable special breadcrumb with dropdown for root containers -->
    <xsl:template match="*[@rdf:about]" mode="bs2:BreadCrumbListItem">
        <xsl:param name="leaf" select="true()" as="xs:boolean"/>
        
        <li>
            <xsl:variable name="class" as="xs:string?">
                <xsl:apply-templates select="." mode="ldh:logo"/>
            </xsl:variable>
            <xsl:apply-templates select="." mode="xhtml:Anchor">
                <xsl:with-param name="id" select="()"/>
                <xsl:with-param name="class" select="$class"/>
            </xsl:apply-templates>

            <xsl:if test="not($leaf)">
                <span class="divider">/</span>
            </xsl:if>
        </li>
    </xsl:template>

</xsl:stylesheet>
