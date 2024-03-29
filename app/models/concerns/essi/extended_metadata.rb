module ESSI

  module ExtendedMetadata
    extend ActiveSupport::Concern

    included do
      property :holding_location,
               predicate: RDF::Vocab::BF2.heldBy,
               multiple: false do |index|
                 index.as :stored_searchable, :facetable
               end
      property :series,
               predicate: RDF::Vocab::BF2.seriesStatement do |index|
                 index.as :stored_searchable, :facetable
               end

      property :physical_description,
               predicate: RDF::Vocab::MODS.physicalExtent,
               multiple: false

      property :campus,
               predicate: RDF::Vocab::MARCRelators.uvp,
               multiple: false do |index|
                 index.as :stored_searchable, :facetable
               end

      property :rights_note, predicate: 'http://purl.org/dc/elements/1.1/rights'

      property :abridger, predicate: RDF::Vocab::MARCRelators.abr
      property :actor, predicate: RDF::Vocab::MARCRelators.act
      property :adapter, predicate: RDF::Vocab::MARCRelators.adp
      property :addressee, predicate: RDF::Vocab::MARCRelators.rcp
      property :analyst, predicate: RDF::Vocab::MARCRelators.anl
      property :animator, predicate: RDF::Vocab::MARCRelators.anm
      property :annotator, predicate: RDF::Vocab::MARCRelators.ann
      property :appellant, predicate: RDF::Vocab::MARCRelators.apl
      property :appellee, predicate: RDF::Vocab::MARCRelators.ape
      property :applicant, predicate: RDF::Vocab::MARCRelators.app
      property :architect, predicate: RDF::Vocab::MARCRelators.arc
      property :arranger, predicate: RDF::Vocab::MARCRelators.arr
      property :art_copyist, predicate: RDF::Vocab::MARCRelators.acp
      property :art_director, predicate: RDF::Vocab::MARCRelators.adi
      property :artist, predicate: RDF::Vocab::MARCRelators.art
      property :artistic_director, predicate: RDF::Vocab::MARCRelators.ard
      property :assignee, predicate: RDF::Vocab::MARCRelators.asg
      property :associated_name, predicate: RDF::Vocab::MARCRelators.asn
      property :attributed_name, predicate: RDF::Vocab::MARCRelators.att
      property :auctioneer, predicate: RDF::Vocab::MARCRelators.auc
      property :author, predicate: RDF::Vocab::MARCRelators.aut
      property :author_in_quotations_or_text_abstracts,
               predicate: RDF::Vocab::MARCRelators.aqt
      property :author_of_afterword_colophon_etc,
               predicate: RDF::Vocab::MARCRelators.aft
      property :author_of_dialog, predicate: RDF::Vocab::MARCRelators.aud
      property :author_of_introduction_etc,
               predicate: RDF::Vocab::MARCRelators.aui
      property :autographer, predicate: RDF::Vocab::MARCRelators.ato
      property :bibliographic_antecedent, predicate: RDF::Vocab::MARCRelators.ant
      property :binder, predicate: RDF::Vocab::MARCRelators.bnd
      property :binding_designer, predicate: RDF::Vocab::MARCRelators.bdd
      property :blurb_writer, predicate: RDF::Vocab::MARCRelators.blw
      property :book_designer, predicate: RDF::Vocab::MARCRelators.bkd
      property :book_producer, predicate: RDF::Vocab::MARCRelators.bkp
      property :bookjacket_designer, predicate: RDF::Vocab::MARCRelators.bjd
      property :bookplate_designer, predicate: RDF::Vocab::MARCRelators.bpd
      property :bookseller, predicate: RDF::Vocab::MARCRelators.bsl
      property :braille_embosser, predicate: RDF::Vocab::MARCRelators.brl
      property :broadcaster, predicate: RDF::Vocab::MARCRelators.brd
      property :calligrapher, predicate: RDF::Vocab::MARCRelators.cll
      property :cartographer, predicate: RDF::Vocab::MARCRelators.ctg
      property :caster, predicate: RDF::Vocab::MARCRelators.cas
      property :censor, predicate: RDF::Vocab::MARCRelators.cns
      property :choreographer, predicate: RDF::Vocab::MARCRelators.chr
      property :cinematographer, predicate: RDF::Vocab::MARCRelators.cng
      property :client, predicate: RDF::Vocab::MARCRelators.cli
      property :collection_registrar, predicate: RDF::Vocab::MARCRelators.cor
      property :collector, predicate: RDF::Vocab::MARCRelators.col
      property :collotyper, predicate: RDF::Vocab::MARCRelators.clt
      property :colorist, predicate: RDF::Vocab::MARCRelators.clr
      property :commentator, predicate: RDF::Vocab::MARCRelators.cmm
      property :commentator_for_written_text,
               predicate: RDF::Vocab::MARCRelators.cwt
      property :compiler, predicate: RDF::Vocab::MARCRelators.com
      property :complainant, predicate: RDF::Vocab::MARCRelators.cpl
      property :complainant_appellant, predicate: RDF::Vocab::MARCRelators.cpt
      property :complainant_appellee, predicate: RDF::Vocab::MARCRelators.cpe
      property :composer, predicate: RDF::Vocab::MARCRelators.cmp
      property :compositor, predicate: RDF::Vocab::MARCRelators.cmt
      property :conceptor, predicate: RDF::Vocab::MARCRelators.ccp
      property :conductor, predicate: RDF::Vocab::MARCRelators.cnd
      property :conservator, predicate: RDF::Vocab::MARCRelators.con
      property :consultant, predicate: RDF::Vocab::MARCRelators.csl
      property :consultant_to_a_project, predicate: RDF::Vocab::MARCRelators.csp
      property :contestant, predicate: RDF::Vocab::MARCRelators.cos
      property :contestant_appellant, predicate: RDF::Vocab::MARCRelators.cot
      property :contestant_appellee, predicate: RDF::Vocab::MARCRelators.coe
      property :contestee, predicate: RDF::Vocab::MARCRelators.cts
      property :contestee_appellant, predicate: RDF::Vocab::MARCRelators.ctt
      property :contestee_appellee, predicate: RDF::Vocab::MARCRelators.cte
      property :contractor, predicate: RDF::Vocab::MARCRelators.ctr
      property :copyright_claimant, predicate: RDF::Vocab::MARCRelators.cpc
      property :copyright_holder, predicate: RDF::Vocab::MARCRelators.cph
      property :corrector, predicate: RDF::Vocab::MARCRelators.crr
      property :correspondent, predicate: RDF::Vocab::MARCRelators.crp
      property :costume_designer, predicate: RDF::Vocab::MARCRelators.cst
      property :court_governed, predicate: RDF::Vocab::MARCRelators.cou
      property :court_reporter, predicate: RDF::Vocab::MARCRelators.crt
      property :cover_designer, predicate: RDF::Vocab::MARCRelators.cov
      property :curator, predicate: RDF::Vocab::MARCRelators.cur
      property :dancer, predicate: RDF::Vocab::MARCRelators.dnc
      property :data_contributor, predicate: RDF::Vocab::MARCRelators.dtc
      property :data_manager, predicate: RDF::Vocab::MARCRelators.dtm
      property :dedicatee, predicate: RDF::Vocab::MARCRelators.dte
      property :dedicator, predicate: RDF::Vocab::MARCRelators.dto
      property :defendant, predicate: RDF::Vocab::MARCRelators.dfd
      property :defendant_appellant, predicate: RDF::Vocab::MARCRelators.dft
      property :defendant_appellee, predicate: RDF::Vocab::MARCRelators.dfe
      property :degree_granting_institution, predicate: RDF::Vocab::MARCRelators.dgg
      property :degree_supervisor, predicate: RDF::Vocab::MARCRelators.dgs
      property :delineator, predicate: RDF::Vocab::MARCRelators.dln
      property :depicted, predicate: RDF::Vocab::MARCRelators.dpc
      property :designer, predicate: RDF::Vocab::MARCRelators.dsr
      property :director, predicate: RDF::Vocab::MARCRelators.drt
      property :dissertant, predicate: RDF::Vocab::MARCRelators.dis
      property :distribution_place, predicate: RDF::Vocab::MARCRelators.dbp
      property :distributor, predicate: RDF::Vocab::MARCRelators.dst
      property :owning_institution, predicate: RDF::Vocab::MARCRelators.dnr
      property :draftsman, predicate: RDF::Vocab::MARCRelators.drm
      property :dubious_author, predicate: RDF::Vocab::MARCRelators.dub
      property :editor, predicate: RDF::Vocab::MARCRelators.edt
      property :editor_of_compilation, predicate: RDF::Vocab::MARCRelators.edc
      property :editor_of_moving_image_work, predicate: RDF::Vocab::MARCRelators.edm
      property :electrician, predicate: RDF::Vocab::MARCRelators.elg
      property :electrotyper, predicate: RDF::Vocab::MARCRelators.elt
      property :enacting_jurisdiction, predicate: RDF::Vocab::MARCRelators.enj
      property :engineer, predicate: RDF::Vocab::MARCRelators.eng
      property :engraver, predicate: RDF::Vocab::MARCRelators.egr
      property :etcher, predicate: RDF::Vocab::MARCRelators.etr
      property :event_place, predicate: RDF::Vocab::MARCRelators.evp
      property :expert, predicate: RDF::Vocab::MARCRelators.exp
      property :facsimilist, predicate: RDF::Vocab::MARCRelators.fac
      property :field_director, predicate: RDF::Vocab::MARCRelators.fld
      property :film_distributor, predicate: RDF::Vocab::MARCRelators.fds
      property :film_director, predicate: RDF::Vocab::MARCRelators.fmd
      property :film_editor, predicate: RDF::Vocab::MARCRelators.flm
      property :film_producer, predicate: RDF::Vocab::MARCRelators.fmp
      property :filmmaker, predicate: RDF::Vocab::MARCRelators.fmk
      property :first_party, predicate: RDF::Vocab::MARCRelators.fpy
      property :forger, predicate: RDF::Vocab::MARCRelators.frg
      property :former_owner, predicate: RDF::Vocab::MARCRelators.fmo
      property :funding, predicate: RDF::Vocab::MARCRelators.fnd
      property :geographic_information_specialist,
               predicate: RDF::Vocab::MARCRelators.gis
      property :honoree, predicate: RDF::Vocab::MARCRelators.hnr
      property :host, predicate: RDF::Vocab::MARCRelators.hst
      property :host_institution, predicate: RDF::Vocab::MARCRelators.his
      property :illuminator, predicate: RDF::Vocab::MARCRelators.ilu
      property :illustrator, predicate: RDF::Vocab::MARCRelators.ill
      property :inscriber, predicate: RDF::Vocab::MARCRelators.ins
      property :instrumentalist, predicate: RDF::Vocab::MARCRelators.itr
      property :interviewee, predicate: RDF::Vocab::MARCRelators.ive
      property :interviewer, predicate: RDF::Vocab::MARCRelators.ivr
      property :author, predicate: RDF::Vocab::MARCRelators.inv
      property :issuing_body, predicate: RDF::Vocab::MARCRelators.isb
      property :judge, predicate: RDF::Vocab::MARCRelators.jud
      property :jurisdiction_governed, predicate: RDF::Vocab::MARCRelators.jug
      property :laboratory, predicate: RDF::Vocab::MARCRelators.lbr
      property :laboratory_director, predicate: RDF::Vocab::MARCRelators.ldr
      property :landscape_architect, predicate: RDF::Vocab::MARCRelators.lsa
      property :lead, predicate: RDF::Vocab::MARCRelators.led
      property :lender, predicate: RDF::Vocab::MARCRelators.len
      property :libelant, predicate: RDF::Vocab::MARCRelators.lil
      property :libelant_appellant, predicate: RDF::Vocab::MARCRelators.lit
      property :libelant_appellee, predicate: RDF::Vocab::MARCRelators.lie
      property :libelee, predicate: RDF::Vocab::MARCRelators.lel
      property :libelee_appellant, predicate: RDF::Vocab::MARCRelators.let
      property :libelee_appellee, predicate: RDF::Vocab::MARCRelators.lee
      property :librettist, predicate: RDF::Vocab::MARCRelators.lbt
      property :licensee, predicate: RDF::Vocab::MARCRelators.lse
      property :licensor, predicate: RDF::Vocab::MARCRelators.lso
      property :lighting_designer, predicate: RDF::Vocab::MARCRelators.lgd
      property :lithographer, predicate: RDF::Vocab::MARCRelators.ltg
      property :lyricist, predicate: RDF::Vocab::MARCRelators.lyr
      property :manufacture_place, predicate: RDF::Vocab::MARCRelators.mfp
      property :manufacturer, predicate: RDF::Vocab::MARCRelators.mfr
      property :marbler, predicate: RDF::Vocab::MARCRelators.mrb
      property :markup_editor, predicate: RDF::Vocab::MARCRelators.mrk
      property :medium, predicate: RDF::Vocab::MARCRelators.med
      property :metadata_contact, predicate: RDF::Vocab::MARCRelators.mdc
      property :metal_engraver, predicate: RDF::Vocab::MARCRelators.mte
      property :minute_taker, predicate: RDF::Vocab::MARCRelators.mtk
      property :moderator, predicate: RDF::Vocab::MARCRelators.mod
      property :monitor, predicate: RDF::Vocab::MARCRelators.mon
      property :music_copyist, predicate: RDF::Vocab::MARCRelators.mcp
      property :musical_director, predicate: RDF::Vocab::MARCRelators.msd
      property :musician, predicate: RDF::Vocab::MARCRelators.mus
      property :narrator, predicate: RDF::Vocab::MARCRelators.nrt
      property :onscreen_presenter, predicate: RDF::Vocab::MARCRelators.osp
      property :opponent, predicate: RDF::Vocab::MARCRelators.opn
      property :organizer, predicate: RDF::Vocab::MARCRelators.orm
      property :originator, predicate: RDF::Vocab::MARCRelators.org
      property :other, predicate: RDF::Vocab::MARCRelators.oth
      property :owner, predicate: RDF::Vocab::MARCRelators.own
      property :panelist, predicate: RDF::Vocab::MARCRelators.pan
      property :papermaker, predicate: RDF::Vocab::MARCRelators.ppm
      property :patent_applicant, predicate: RDF::Vocab::MARCRelators.pta
      property :patent_holder, predicate: RDF::Vocab::MARCRelators.pth
      property :patron, predicate: RDF::Vocab::MARCRelators.pat
      property :performer, predicate: RDF::Vocab::MARCRelators.prf
      property :permitting_agency, predicate: RDF::Vocab::MARCRelators.pma
      property :photographer, predicate: RDF::Vocab::MARCRelators.pht
      property :plaintiff, predicate: RDF::Vocab::MARCRelators.ptf
      property :plaintiff_appellant, predicate: RDF::Vocab::MARCRelators.ptt
      property :plaintiff_appellee, predicate: RDF::Vocab::MARCRelators.pte
      property :platemaker, predicate: RDF::Vocab::MARCRelators.plt
      property :praeses, predicate: RDF::Vocab::MARCRelators.pra
      property :presenter, predicate: RDF::Vocab::MARCRelators.pre
      property :printer, predicate: RDF::Vocab::MARCRelators.prt
      property :printer_of_plates, predicate: RDF::Vocab::MARCRelators.pop
      property :printmaker, predicate: RDF::Vocab::MARCRelators.prm
      property :process_contact, predicate: RDF::Vocab::MARCRelators.prc
      property :producer, predicate: RDF::Vocab::MARCRelators.pro
      property :production_company, predicate: RDF::Vocab::MARCRelators.prn
      property :production_designer, predicate: RDF::Vocab::MARCRelators.prs
      property :production_manager, predicate: RDF::Vocab::MARCRelators.pmn
      property :production_personnel, predicate: RDF::Vocab::MARCRelators.prd
      property :production_place, predicate: RDF::Vocab::MARCRelators.prp
      property :programmer, predicate: RDF::Vocab::MARCRelators.prg
      property :project_director, predicate: RDF::Vocab::MARCRelators.pdr
      property :proofreader, predicate: RDF::Vocab::MARCRelators.pfr
      property :provider, predicate: RDF::Vocab::MARCRelators.prv
      property :publication_place, predicate: RDF::Vocab::MARCRelators.pup
      property :publishing_director, predicate: RDF::Vocab::MARCRelators.pbd
      property :puppeteer, predicate: RDF::Vocab::MARCRelators.ppt
      property :radio_director, predicate: RDF::Vocab::MARCRelators.rdd
      property :radio_producer, predicate: RDF::Vocab::MARCRelators.rpc
      property :recording_engineer, predicate: RDF::Vocab::MARCRelators.rce
      property :recordist, predicate: RDF::Vocab::MARCRelators.rcd
      property :redaktor, predicate: RDF::Vocab::MARCRelators.red
      property :renderer, predicate: RDF::Vocab::MARCRelators.ren
      property :reporter, predicate: RDF::Vocab::MARCRelators.rpt
      property :marc_repository, predicate: RDF::Vocab::MARCRelators.rps
      property :research_team_head, predicate: RDF::Vocab::MARCRelators.rth
      property :research_team_member, predicate: RDF::Vocab::MARCRelators.rtm
      property :researcher, predicate: RDF::Vocab::MARCRelators.res
      property :respondent, predicate: RDF::Vocab::MARCRelators.rsp
      property :respondent_appellant, predicate: RDF::Vocab::MARCRelators.rst
      property :respondent_appellee, predicate: RDF::Vocab::MARCRelators.rse
      property :responsible_party, predicate: RDF::Vocab::MARCRelators.rpy
      property :restager, predicate: RDF::Vocab::MARCRelators.rsg
      property :restorationist, predicate: RDF::Vocab::MARCRelators.rsr
      property :reviewer, predicate: RDF::Vocab::MARCRelators.rev
      property :rubricator, predicate: RDF::Vocab::MARCRelators.rbr
      property :scenarist, predicate: RDF::Vocab::MARCRelators.sce
      property :scientific_advisor, predicate: RDF::Vocab::MARCRelators.sad
      property :screenwriter, predicate: RDF::Vocab::MARCRelators.aus
      property :scribe, predicate: RDF::Vocab::MARCRelators.scr
      property :sculptor, predicate: RDF::Vocab::MARCRelators.scl
      property :second_party, predicate: RDF::Vocab::MARCRelators.spy
      property :secretary, predicate: RDF::Vocab::MARCRelators.sec
      property :seller, predicate: RDF::Vocab::MARCRelators.sll
      property :set_designer, predicate: RDF::Vocab::MARCRelators.std
      property :setting, predicate: RDF::Vocab::MARCRelators.stg
      property :signer, predicate: RDF::Vocab::MARCRelators.sgn
      property :singer, predicate: RDF::Vocab::MARCRelators.sng
      property :sound_designer, predicate: RDF::Vocab::MARCRelators.sds
      property :speaker, predicate: RDF::Vocab::MARCRelators.spk
      property :sponsor, predicate: RDF::Vocab::MARCRelators.spn
      property :stage_director, predicate: RDF::Vocab::MARCRelators.sgd
      property :stage_manager, predicate: RDF::Vocab::MARCRelators.stm
      property :standards_body, predicate: RDF::Vocab::MARCRelators.stn
      property :stereotyper, predicate: RDF::Vocab::MARCRelators.str
      property :storyteller, predicate: RDF::Vocab::MARCRelators.stl
      property :supporting_host, predicate: RDF::Vocab::MARCRelators.sht
      property :surveyor, predicate: RDF::Vocab::MARCRelators.srv
      property :teacher, predicate: RDF::Vocab::MARCRelators.tch
      property :technical_director, predicate: RDF::Vocab::MARCRelators.tcd
      property :television_director, predicate: RDF::Vocab::MARCRelators.tld
      property :television_producer, predicate: RDF::Vocab::MARCRelators.tlp
      property :thesis_advisor, predicate: RDF::Vocab::MARCRelators.ths
      property :transcriber, predicate: RDF::Vocab::MARCRelators.trc
      property :translator, predicate: RDF::Vocab::MARCRelators.trl
      property :type_designer, predicate: RDF::Vocab::MARCRelators.tyd
      property :typographer, predicate: RDF::Vocab::MARCRelators.tyg
      property :videographer, predicate: RDF::Vocab::MARCRelators.vdg
      property :voice_actor, predicate: RDF::Vocab::MARCRelators.vac
      property :witness, predicate: RDF::Vocab::MARCRelators.wit
      property :wood_engraver, predicate: RDF::Vocab::MARCRelators.wde
      property :woodcutter, predicate: RDF::Vocab::MARCRelators.wdc
      property :writer_of_accompanying_material,
               predicate: RDF::Vocab::MARCRelators.wam
      property :writer_of_added_commentary,
               predicate: RDF::Vocab::MARCRelators.wac
      property :writer_of_added_text, predicate: RDF::Vocab::MARCRelators.wat
      property :writer_of_added_lyrics, predicate: RDF::Vocab::MARCRelators.wal
      property :writer_of_supplementary_textual_content,
               predicate: RDF::Vocab::MARCRelators.wst
      property :writer_of_introduction, predicate: RDF::Vocab::MARCRelators.win
      property :writer_of_preface, predicate: RDF::Vocab::MARCRelators.wpr
    end
  end
end
