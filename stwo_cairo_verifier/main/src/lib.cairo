use stwo_cairo_verifier::verifier::{StarkProof, verify};
use stwo_cairo_verifier::airs::fib::HorizontalFibAir;
use stwo_cairo_verifier::fri::FriConfig;
use stwo_cairo_verifier::pcs::PcsConfig;
use stwo_cairo_verifier::channel::ChannelImpl;
use stwo_cairo_verifier::pcs::verifier::{CommitmentSchemeVerifierImpl};
use stwo_cairo_verifier::utils::ArrayImpl;

#[executable]
fn main(proof: StarkProof) {
    let config = PcsConfig {
        pow_bits: 0,
        fri_config: FriConfig {
            log_last_layer_degree_bound: 4, log_blowup_factor: 4, n_queries: 15,
        },
    };

    // Verify.
    let log_size = 20;
    let air = HorizontalFibAir::<128> { log_size };
    let mut channel = ChannelImpl::new(0);
    let mut commitment_scheme = CommitmentSchemeVerifierImpl::new(config);

    // Decommit.
    commitment_scheme.commit(*proof.commitment_scheme_proof.commitments[0], @array![], ref channel);
    commitment_scheme
        .commit(
            *proof.commitment_scheme_proof.commitments[1],
            @ArrayImpl::new_repeated(128, log_size),
            ref channel,
        );

    if let Result::Err(err) = verify(air, ref channel, proof, ref commitment_scheme) {
        panic!("Verification failed: {:?}", err);
    }
}
