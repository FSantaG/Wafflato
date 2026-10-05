--- STEAMODDED HEADER
--- MOD_NAME: Wafflatro
--- MOD_ID: Wafflatro
--- MOD_AUTHOR: [Waffle]
--- MOD_DESCRIPTION: A silly mod
--- BADGE_COLOUR: 000000

----------------------------------------------
------------MOD CODE -------------------------


local jokers = {
    joseantonio = {
        name = "José Antonio",
        rarity = 4,
        cost = 15,
        blueprint_compat = false,
        eternal_compat = true,
        text = {
            "After selecting a {C:attention}Blind{},",
            "a random {C:attention}Joker{} become",
            "{C:attention}Negative{}",
            "{C:inactive}Ploshia, Jose Antonio...This ancient god receives thousands of names...{C:inactive}"
        },
        calculate = function(self, context)
            if context.setting_blind and not context.blueprint then
                local eligible_jokers = {}
                for k, v in pairs(G.jokers.cards) do
                    table.insert(eligible_jokers, v)
                end

                eligible_card = pseudorandom_element(eligible_jokers, pseudoseed('tetas'))
                local edition = {negative = true}
                eligible_card:set_edition(edition, true)
                G.E_MANAGER:add_event(Event({
                        func = function()
                            eligible_card:juice_up()
                            return true
                        end
                    }))

                return {
                            message = "NEGATIVE!",
                            card = self,
                            colour = G.C.BLACK
                        }
            end
        end
    },
    waffletower = {
        name = "Tower of Waffles",
        rarity = 2,
        cost = 7,
        blueprint_compat = true,
        eternal_compat = true,
        text = {
            "Gives {X:red,C:white}X#1#{} {C:mult}Mult{}.",
            "Reduced by {C:attention}#2#{} every {C:attention}Blind{}",
            "{C:inactive}A waffle over a waffle over a w...{C:inactive}"
        },
        config = {
            extra = {
                total_mult = 4,
                mult_loss_per_round = 1,
                already_triggered_this_round = false
            }
        },

        calculate = function(self, context)
            local extra = self.ability.extra
            if context.setting_blind and not context.blueprint then
                extra.already_triggered_this_round = false
            end

            if context.end_of_round then
                if not extra.already_triggered_this_round then
                    extra.total_mult = extra.total_mult - extra.mult_loss_per_round
                    extra.already_triggered_this_round = true
                    if extra.total_mult == 0 then
                        self:remove()
                        return {
                            message = "NU WAFFLES :(",
                            colour = G.C.RED
                        }
                    end
                end
            end
            if context.joker_main and context.full_hand then
                if extra.total_mult > 0 then
                    return {
                        Xmult_mod = self.ability.extra.total_mult,
                        colour = G.C.XMULT,
                        card = self,
                        message = "TASTY WAFFLES!"
                    }
                end
            end
        end,
        
        loc_def = function(self)
            local extra = self.ability.extra
            return {
                extra.total_mult,
                extra.mult_loss_per_round or 1
            }
        end
    },
    sharpshooter = {
        name = "Sharpshooter",
        rarity = 3,
        cost = 10,
        blueprint_compat = false,
        eternal_compat = true,
        config = { 
            extra = { 
                xmult = 2 
            } 
        },
        text = {
            "Scoring {C:attention}cards{}",
            "become {C:attention}Wild{} cards.",
            "Each {C:attention}Wild{} card gives",
            "{X:red,C:white}X2{} {C:mult}Mult{}.",
            "{C:inactive}She will kill you if you call her cute{C:inactive}"
        },

        calculate = function(self, context)
            local extra = self.ability.extra
            if context.before and not context.blueprint then
                for k, v in ipairs(context.scoring_hand) do
                    v:set_ability(G.P_CENTERS.m_wild, nil, true)
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            v:juice_up()
                            return true
                        end
                    }))
                end
                return {
                    message = "Pew pew!",
                    colour = G.C.RED
                }
            end

            if context.individual and context.cardarea == G.play and
            SMODS.has_enhancement(context.other_card, 'm_wild') then
                return {
                    Xmult_mod = extra.xmult,
                    colour = G.C.XMULT,
                    card = self,
                    message = "X2"
                }
            end
        end,
        in_pool = function(self, args) 
            for _, playing_card in ipairs(G.playing_cards or {}) do
                if SMODS.has_enhancement(playing_card, 'm_wild') then
                    return true
                end
            end
            return false
        end,
    },
    lesbiancouple = {
        name = "Lesbian Couple",
        rarity = 1,
        cost = 4,
        blueprint_compat = true,
        eternal_compat = true,
        config = { 
            extra = { 
                xmult = 1.25,
                chips = 50
            } 
        },
        text = {
            "Scoring {C:attention}Queens{}",
            "gives {X:red,C:white}X1.25{} {C:mult}Mult{}",
            "and {C:chips}50{} chips",
            "{C:inactive}Mommies{C:inactive}"
        },

        calculate = function(self, context)
            
            if context.individual and context.cardarea == G.play and context.other_card:get_id() == 12 then
                return {
                    xmult = self.ability.extra.xmult,
                    chips = self.ability.extra.chips
                }
            end
        end,
    },
    jojopose = {
        name = "Jojo Posing",
        rarity = 2,
        cost = 7,
        blueprint_compat = true,
        eternal_compat = true,
        text = {
            "Retriggers {C:attention}all{} cards",
            "{C:inactive}IS THIS A FREAKIN' JOJO REFERENCE?!{C:inactive}"
        },

        calculate = function(self, context)
                if context.repetition and context.cardarea == G.play then
                    return {
                        repetitions = 1,
                        message = "YES",
                        colour = G.C.PURPLE,
                        card = self
                    }
                end
        end
    },
    heart = {
        name = "Heart of Perú",
        rarity = 4,
        cost = 15,
        blueprint_compat = false,
        eternal_compat = true,
        text = {
            "Scoring {C:hearts}Heart{} cards",
            "become either {C:attention}polychrome{}, ",
            "{C:attention}holographic{} or {C:attention}foil{}",
            "{C:inactive}Sponsored by Inca Kola{C:inactive}"
        },

        calculate = function(self, context)
            if context.before and not context.blueprint then    
                    local has_noedition = false
                    local any_edition = false

                    for k, v in ipairs(context.scoring_hand) do
                        if not v.edition then
                            has_noedition = true
                            break
                        end
                    end

                    if has_noedition then
                        for k, v in ipairs(context.scoring_hand) do
                            if not v.edition and v:is_suit("Hearts") then
                                G.E_MANAGER:add_event(Event({
                                    func = function()
                                        local edition_type = pseudorandom(pseudoseed('certsl'))
                                        if edition_type > 0.75 then v:set_edition({ polychrome = true })
                                        elseif edition_type > 0.5 then v:set_edition({ holo = true })
                                        else v:set_edition({ foil = true })
                                        end
                                        v:juice_up()
                                        G.hand:sort()
                                        any_sealed = true
                                        return true
                                end}))
                                              
                            end
                        end
                    end

                    if not any_sealed then
                    return {
                        message = "Empanadas",
                        colour = G.C.RED,
                        card = self
                    }
                    end
            end
        end,
    },
    diamond = {
        name = "LidiaCoin",
        rarity = 4,
        cost = 15,
        blueprint_compat = false,
        eternal_compat = true,
        text = {
            "Scoring {C:diamonds}Diamond{} cards",
            "become either {C:attention}polychrome{}, ",
            "{C:attention}holographic{} or {C:attention}foil{}",
            "{C:inactive}Infinite value, negative brain{C:inactive}"
        },

        calculate = function(self, context)
            if context.before and not context.blueprint then    
                    local has_noedition = false
                    local any_edition = false

                    for k, v in ipairs(context.scoring_hand) do
                        if not v.edition then
                            has_noedition = true
                            break
                        end
                    end

                    if has_noedition then
                        for k, v in ipairs(context.scoring_hand) do
                            if not v.edition and v:is_suit("Diamonds") then
                                G.E_MANAGER:add_event(Event({
                                    func = function()
                                        local edition_type = pseudorandom(pseudoseed('certsl'))
                                        if edition_type > 0.75 then v:set_edition({ polychrome = true })
                                        elseif edition_type > 0.5 then v:set_edition({ holo = true })
                                        else v:set_edition({ foil = true })
                                        end
                                        v:juice_up()
                                        G.hand:sort()
                                        any_sealed = true
                                        return true
                                end}))
                                              
                            end
                        end
                    end

                    if not any_sealed then
                    return {
                        message = "Ey!",
                        colour = G.C.RED,
                        card = self
                    }
                    end
            end
        end,
    },
    spade = {
        name = "Ace of Ikklubs",
        rarity = 4,
        cost = 15,
        blueprint_compat = false,
        eternal_compat = true,
        text = {
            "Scoring {C:clubs}Club{} cards",
            "become either {C:attention}polychrome{}, ",
            "{C:attention}holographic{} or {C:attention}foil{}",
            "{C:inactive}It has the power to tear a community apart...{C:inactive}"
        },

        calculate = function(self, context)
            if context.before and not context.blueprint then    
                    local has_noedition = false
                    local any_edition = false

                    for k, v in ipairs(context.scoring_hand) do
                        if not v.edition then
                            has_noedition = true
                            break
                        end
                    end

                    if has_noedition then
                        for k, v in ipairs(context.scoring_hand) do
                            if not v.edition and v:is_suit("Spades") then
                                G.E_MANAGER:add_event(Event({
                                    func = function()
                                        local edition_type = pseudorandom(pseudoseed('certsl'))
                                        if edition_type > 0.75 then v:set_edition({ polychrome = true })
                                        elseif edition_type > 0.5 then v:set_edition({ holo = true })
                                        else v:set_edition({ foil = true })
                                        end
                                        v:juice_up()
                                        G.hand:sort()
                                        any_sealed = true
                                        return true
                                end}))
                                              
                            end
                        end
                    end

                    if not any_sealed then
                    return {
                        message = "Ya está en tiendas.",
                        colour = G.C.RED,
                        card = self
                    }
                    end
            end
        end,
    },
    club = {
        name = "Four-leaf Waffle",
        rarity = 4,
        cost = 15,
        blueprint_compat = false,
        eternal_compat = true,
        text = {
            "Scoring {C:clubs}Club{} cards",
            "become either {C:attention}polychrome{}, ",
            "{C:attention}holographic{} or {C:attention}foil{}",
            "{C:inactive}Sublime{C:inactive}"
        },

        calculate = function(self, context)
            if context.before and not context.blueprint then    
                    local has_noedition = false
                    local any_edition = false

                    for k, v in ipairs(context.scoring_hand) do
                        if not v.edition then
                            has_noedition = true
                            break
                        end
                    end

                    if has_noedition then
                        for k, v in ipairs(context.scoring_hand) do
                            if not v.edition and v:is_suit("Clubs") then
                                G.E_MANAGER:add_event(Event({
                                    func = function()
                                        local edition_type = pseudorandom(pseudoseed('certsl'))
                                        if edition_type > 0.75 then v:set_edition({ polychrome = true })
                                        elseif edition_type > 0.5 then v:set_edition({ holo = true })
                                        else v:set_edition({ foil = true })
                                        end
                                        v:juice_up()
                                        G.hand:sort()
                                        any_sealed = true
                                        return true
                                end}))
                                              
                            end
                        end
                    end

                    if not any_sealed then
                    return {
                        message = "CUATRO!",
                        colour = G.C.RED,
                        card = self
                    }
                    end
            end
        end,
    }

}

function SMODS.INIT.Wafflatro()
    --localization for the info queue key
    G.localization.descriptions.Other["your_key"] = {
        name = "Example", --tooltip name
        text = {
            "TEXT L1",   --tooltip text.		
            "TEXT L2",   --you can add as many lines as you want
            "TEXT L3"    --more than 5 lines look odd
        }
    }
    init_localization()

    --Create and register jokers
    for k, v in pairs(jokers) do
        local joker = SMODS.Joker:new(v.name, k, v.config, v.pos, { name = v.name, text = v.text }, v.rarity, v.cost,
            v.unlocked, v.discovered, v.blueprint_compat, v.eternal_compat, v.effect, v.atlas, v.soul_pos)
        joker:register()

        if not v.atlas then --if atlas=nil then use single sprites. In this case you have to save your sprite as slug.png (for example j_examplejoker.png)
            SMODS.Sprite:new("j_" .. k, SMODS.findModByID("Wafflatro").path, "j_" .. k .. ".png", 71, 95, "asset_atli")
                :register()
        end

        --add jokers calculate function:
        SMODS.Jokers[joker.slug].calculate = v.calculate
        --add jokers loc_def:
        SMODS.Jokers[joker.slug].loc_def = v.loc_def

        --if tooltip is present, add jokers tooltip
        if (v.tooltip ~= nil) then
            SMODS.Jokers[joker.slug].tooltip = v.tooltip
        end
    end
    --Create sprite atlas
    SMODS.Sprite:new("youratlasname", SMODS.findModByID("Wafflatro").path, "example.png", 71, 95, "asset_atli")
        :register()
end

----------------------------------------------
------------MOD CODE END----------------------