//
// Run SNPEFF to annotate VCF files
//

include { SNPEFF_SNPEFF    } from '../../../modules/nf-core/snpeff/snpeff/main.nf'
include { TABIX_BGZIPTABIX } from '../../../modules/nf-core/tabix/bgziptabix/main.nf'

workflow VCF_ANNOTATE_SNPEFF {
    take:
    vcf          // channel: [ val(meta), vcf ]
    snpeff_db    //   value: db version to use
    snpeff_cache //    path: /path/to/snpeff/cache (optionnal)

    main:
    ch_versions = Channel.empty()

    SNPEFF_SNPEFF(vcf, snpeff_db, snpeff_cache)
    TABIX_BGZIPTABIX(SNPEFF_SNPEFF.out.vcf)

    // Gather versions of all tools used
    ch_versions = ch_versions.mix(SNPEFF_SNPEFF.out.versions)
    ch_versions = ch_versions.mix(TABIX_BGZIPTABIX.out.versions)

    emit:
    vcf_tbi  = TABIX_BGZIPTABIX.out.gz_tbi // channel: [ val(meta), vcf.gz, vcf.gz.tbi ]
    reports  = SNPEFF_SNPEFF.out.report           //    path: *.html
    versions = ch_versions                 //    path: versions.yml
}
