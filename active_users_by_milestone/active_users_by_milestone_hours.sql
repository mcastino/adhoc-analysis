create table ds_prod.prototype.active_users_by_milestone_hours as (

with milestones as (
   select
        milestone
   from ds_prod.prototype.milestone_hours
),
subscribers as (
    select
        distinct brand_owning_user_id as user_id,
        trial_started_at
    from ds_prod.model.dim_subscription
    where trial_started_at between '2020-01-01' and '2020-07-01'
),
users as (
    select
        du.user_id,
        du.signup_platform,
        du.signed_up_at,
        dc.market,
        du.last_active_at,
        case
            when s.user_id is not null then true
            else false
        end as trialling_user
    from ds_prod.model.dim_user du
    left join ds_prod.model.dim_country dc
        on du.country_name = dc.country_name
    left join subscribers s
        on du.user_id = s.user_id
        and du.signed_up_at::date = s.trial_started_at::date
    where signed_up_at between '2020-01-01' and '2020-07-01'
        and not du.is_internal_user
),
user_totals as (
    select
        market,
        signup_platform,
        trialling_user,
        count(1) as total_users
    from users
    group by 1,2,3
),
user_milestones as (
    select
        u.user_id,
        u.signup_platform,
        u.signed_up_at,
        u.market,
        u.trialling_user,
        u.last_active_at,
        m.milestone,
        case
            when m.milestone = -1 then 1
            when datediff('hours',signed_up_at,last_active_at) >= m.milestone then 1
            else null
        end as active
    from users as u
    cross join milestones as m
    order by user_id, milestone
)
select
    um.market,
    um.signup_platform,
    um.trialling_user,
    um.milestone,
    ut.total_users,
    count(um.active) as active_users,
    active_users/total_users as proportion_active
from user_milestones um
left join user_totals ut
    on um.market = ut.market
    and um.signup_platform = ut.signup_platform
    and um.trialling_user = ut.trialling_user
group by 1,2,3,4,5
order by 1,2,3,4
)

;


create table ds_prod.prototype.active_users_by_milestone_hours as (

with milestones as (
   select
        milestone
   from ds_prod.prototype.milestone_hours
),
subscribers as (
    select
        distinct brand_owning_user_id as user_id,
        trial_started_at
    from ds_prod.model.dim_subscription
    where trial_started_at between '2020-01-01' and '2020-07-01'
),
users as (
    select
        du.user_id,
        du.signup_platform,
        du.signed_up_at,
        dc.market,
        du.last_active_at,
        case
            when s.user_id is not null then true
            else false
        end as trialling_user
    from ds_prod.model.dim_user du
    left join ds_prod.model.dim_country dc
        on du.country_name = dc.country_name
    left join subscribers s
        on du.user_id = s.user_id
        and du.signed_up_at::date = s.trial_started_at::date
    where signed_up_at between '2020-01-01' and '2020-07-01'
        and not du.is_internal_user
),
user_totals as (
    select
        market,
        signup_platform,
        trialling_user,
        count(1) as total_users
    from users
    group by 1,2,3
),
user_milestones as (
    select
        u.user_id,
        u.signup_platform,
        u.signed_up_at,
        u.market,
        u.trialling_user,
        u.last_active_at,
        m.milestone,
        case
            when m.milestone = -1 then 1
            when datediff('hours',signed_up_at,last_active_at) >= m.milestone then 1
            else null
        end as active
    from users as u
    cross join milestones as m
    order by user_id, milestone
)
select
    um.market,
    um.signup_platform,
    um.trialling_user,
    um.milestone,
    ut.total_users,
    count(um.active) as active_users,
    active_users/total_users as proportion_active
from user_milestones um
left join user_totals ut
    on um.market = ut.market
    and um.signup_platform = ut.signup_platform
    and um.trialling_user = ut.trialling_user
group by 1,2,3,4,5
order by 1,2,3,4
)
