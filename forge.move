module 0x0::forge {
    use sui::object::{Self, ID, UID};
    use sui::url::{Self, Url};
    use sui::transfer;
    use sui::tx_context::{sender, Self, TxContext};
    use sui::event;

    use sui::package;
    use sui::display;

    use std::string;

    struct FORGE has drop { }

    struct NFT has key, store {
        id: UID,
        name: string::String,
        description: string::String,
        img_url: string::String,
    }

    struct NFTMinted has drop, copy {
        object_id: ID,
        creator: address,
        name: string::String,
    }

    fun init(otw: FORGE, ctx: &mut TxContext) {
        let keys = vector[
            string::utf8(b"name"),
            string::utf8(b"image_url"),
            string::utf8(b"description"),
        ];

        let values = vector[
            string::utf8(b"{name}"),
            string::utf8(b"{img_url}"),
            string::utf8(b"{description}"),
        ];

        let publisher = package::claim(otw, ctx);

        let display = display::new_with_fields<NFT>(
            &publisher, keys, values, ctx
        );


        display::update_version(&mut display);

        transfer::public_transfer(publisher, sender(ctx));
        transfer::public_transfer(display, sender(ctx));
    }


    public entry fun mint(
        name: vector<u8>,
        description: vector<u8>,
        img_url: vector<u8>,
        recipient: address,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        let nft = NFT {
            id: object::new(ctx),
            name: string::utf8(name),
            description: string::utf8(description),
            img_url: string::utf8(img_url),
        };

        event::emit(NFTMinted {
            object_id: object::id(&nft),
            creator: recipient,
            name: nft.name,
        });

        transfer::public_transfer(nft, recipient);
    }
}